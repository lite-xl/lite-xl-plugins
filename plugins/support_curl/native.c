#include <curl/curl.h>
#include <string.h>
#include "lite_xl_plugin_api.h"

#define API_TYPE_CURL "curl"
#define CURL_POLL_TIMEOUT 1

static size_t f_curl_write_data(void *buffer, size_t size, size_t nmemb, void *handle) {
  lua_State* L; 
  curl_easy_getinfo(handle, CURLINFO_PRIVATE, &L);
  lua_pushlightuserdata(L, handle);
  lua_rawget(L, LUA_REGISTRYINDEX);
  lua_rawgeti(L, -1, 3);
  if (lua_isnil(L, -1)) {
    lua_pop(L, 1);
    lua_pushliteral(L, "");
  }
  lua_pushlstring(L, buffer, nmemb*size);
  lua_concat(L, 2);
  lua_rawseti(L, -2, 3);
  lua_pop(L, 1);
  return size*nmemb;
}

static int f_curl_request(lua_State* L) {
  lua_getfield(L, 1, "handle");
  CURLM* multi_handle = lua_touserdata(L, -1);
  lua_pop(L, 1);
  lua_getfield(L, 2, "method"); if (lua_isnil(L, -1)) return luaL_error(L, "requires a method");
  const char* method = lua_tostring(L, -1);
  lua_getfield(L, 2, "url"); if (lua_isnil(L, -1)) return luaL_error(L, "requires a url");
  const char* url = lua_tostring(L, -1);
  lua_getfield(L, 2, "timeout"); if (lua_isnil(L, -1)) return luaL_error(L, "requires a timeout");
  lua_Number timeout = lua_tonumber(L, -1);
  lua_getfield(L, 2, "verbose"); if (lua_isnil(L, -1)) return luaL_error(L, "requires verbose");
  int verbose = lua_toboolean(L, -1);
  lua_getfield(L, 2, "done"); if (lua_isnil(L, -1)) return luaL_error(L, "requires done"); 
  int doneIdx = lua_gettop(L);
  lua_getfield(L, 2, "fail"); if (lua_isnil(L, -1)) return luaL_error(L, "requires fail"); 
  int failIdx = lua_gettop(L);
  lua_getfield(L, 2, "headers"); if (lua_isnil(L, -1)) return luaL_error(L, "requires headers"); 
  int headersIdx = lua_gettop(L);
  CURL* handle = curl_easy_init();
  curl_easy_setopt(handle, CURLOPT_URL, url);
  if (strcmp(method, "GET") != 0) {
    curl_easy_setopt(handle, CURLOPT_CUSTOMREQUEST, method);
    lua_getfield(L, 2, "body"); if (lua_isnil(L, -1)) return luaL_error(L, "requires body");
    size_t bodyLen;
    const char* body = lua_tolstring(L, 1, &bodyLen);
    curl_easy_setopt(handle, CURLOPT_POSTFIELDS, body);
  }
  struct curl_slist *headers = NULL;
  char header_buffer[1024];
  lua_pushvalue(L, headersIdx);
  lua_pushnil(L);
  while (lua_next(L, -2)) {
      lua_pushvalue(L, -2);
      snprintf(header_buffer, sizeof(header_buffer), "%s: %s", lua_tostring(L, -1), lua_tostring(L, -2));
      headers = curl_slist_append(headers, header_buffer);
      lua_pop(L, 2);
  }
  lua_pop(L, 1);
  curl_easy_setopt(handle, CURLOPT_HTTPHEADER, headers);
  curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, f_curl_write_data);
  curl_easy_setopt(handle, CURLOPT_TIMEOUT_MS, (long)(timeout*1000));
  curl_easy_setopt(handle, CURLOPT_FAILONERROR, 1L);
  curl_easy_setopt(handle, CURLOPT_ACCEPT_ENCODING, "br, gzip, deflate");
  curl_easy_setopt(handle, CURLOPT_VERBOSE, verbose);
  lua_pushlightuserdata(L, handle);
  lua_newtable(L);
  lua_pushvalue(L, doneIdx);
  lua_rawseti(L, -2, 1);
  lua_pushvalue(L, failIdx);
  lua_rawseti(L, -2, 2);
  lua_rawset(L, LUA_REGISTRYINDEX);
  curl_easy_setopt(handle, CURLOPT_PRIVATE, L);
  curl_easy_setopt(handle, CURLOPT_WRITEDATA, handle);
  CURLMcode code = curl_multi_add_handle(multi_handle, handle);
  if (code)
    return luaL_error(L, "error adding request: %d", code);
  fflush(stderr);
  return 0;
}

static int f_curl_step(lua_State* L) {
  lua_getfield(L, 1, "handle");
  CURLM* multi_handle = lua_touserdata(L, -1);
  int transfers_running;
  CURLMcode mc = curl_multi_perform(multi_handle, &transfers_running);
  if (mc)
    return luaL_error(L, "curl_multi_perform() failed, code %d.\n", (int)mc);
  CURLMsg *m = NULL;
  do {
    int msgq = 0;
    m = curl_multi_info_read(multi_handle, &msgq);
    if(m && (m->msg == CURLMSG_DONE)) {
      CURL *handle = m->easy_handle;
      lua_getfield(L, 1, "requests");
      size_t len = lua_rawlen(L, 2);
      lua_newtable(L);
      size_t newLen = 0;
      for (int i = 1; i <= len; ++i) {
        lua_rawgeti(L, 2, i);
        if (lua_touserdata(L, -1) != handle)
          lua_rawseti(L, 3, ++newLen);
      }
      lua_pushlightuserdata(L, handle);
      lua_rawget(L, LUA_REGISTRYINDEX);
      curl_multi_remove_handle(multi_handle, handle);
      curl_easy_cleanup(handle);
      lua_rawgeti(L, -1, m->data.result == CURLE_OK ? 1 : 2);
      lua_rawgeti(L, -2, 3);
      lua_pushstring(L, curl_easy_strerror(m->data.result));
      lua_call(L, 2, 0);
    }
  } while(m);
  lua_pushboolean(L, transfers_running > 0);
  return 1;
}

static int f_curl_gc(lua_State* L) {
  lua_getfield(L, -1, "handle");
  CURLM* multi_handle = lua_touserdata(L, -1);
  curl_multi_cleanup(multi_handle);
  lua_getfield(L, -1, "requests");
  size_t len = lua_rawlen(L, -1);
  for (int i = 0; i < len; ++i) {
    lua_rawgeti(L, -1, i+1);
    curl_easy_cleanup(lua_touserdata(L, -1));
  }
}

static int f_curl_new(lua_State* L) {
  lua_newtable(L);
  lua_pushliteral(L, "handle");
  lua_pushlightuserdata(L, curl_multi_init());
  lua_rawset(L, -3);
  lua_pushliteral(L, "requests");
  lua_newtable(L);
  lua_rawset(L, -3);
  luaL_setmetatable(L, API_TYPE_CURL);
  return 1;
}

static const struct luaL_Reg lib[] = {
  {"__gc", f_curl_gc},
  {"step", f_curl_step},
  {"request", f_curl_request},
  {"new", f_curl_new},
  {NULL, NULL}
};

int luaopen_lite_xl_native(lua_State* L, void* XL) {
  lite_xl_plugin_init(XL);
  luaL_newmetatable(L, API_TYPE_CURL);
  luaL_setfuncs(L, lib, 0);
  lua_pushvalue(L, -1);
  lua_setfield(L, -2, "__index");
  return 1;
}
