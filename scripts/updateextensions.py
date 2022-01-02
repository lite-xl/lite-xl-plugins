import json
import hashlib
from urllib.request import urlopen, Request
import httplib2
import requests

HEAD = "https://github.com"
repos = ["plugin","lite-xl/lite-xl-plugins","color","lite-xl/lite-xl-colors"]
branches = ["master", "main"]

def get_name(content):
  return content.split("[`",1)[1].split("`]",1)[0]

def get_description(content, etype, name):
  if etype == "color":
    return name
  return content.split("| ",2)[2].split("|",1)[0].split("*",1)[0]

def get_url(content, head):
    url = content.split("(")[1].split(")")[0].replace("\\","")
    try:
      url.index("http")
      return url
    except:
      return head +"/"+ url

def get_author(url):
  return url.replace("://","").split(".com/",1)[1].split("/",1)[0]

def is_sep(url):
  try:
      url.find("lite-xl-plugins")
      return False
  except:
      try:
          url.find("lite-xl-colors")
          return False
      except:
          return True


def get_version_patch_mod(url,special_url, etype):
    patch_url = Request(url,
                headers={'User-Agent': 'Mozilla/5.0'})
    new_response_byte = urlopen(patch_url).read()
    #new_response = new_response_byte.decode()
    mod = 0
    patch = hashlib.sha224(new_response_byte).hexdigest()

    patch_url = Request(special_url,
                headers={'User-Agent': 'Mozilla/5.0'})
    new_response = urlopen(patch_url).read().decode()
    if etype == "color":
      return "master", patch, 0
    try:
      try:
        mod = int(new_response.split("-- mod-version:",1)[1].split(" ")[0].encode())
      except:
        mod = int(new_response.split("-- mod-version:",1)[1].split("\n").encode())
    except:
      try:
        special_url = special_url.replace("master","main")
        patch_url = Request(special_url,
                headers={'User-Agent': 'Mozilla/5.0'})
        new_response = urlopen(patch_url).read().decode()
        try:
          mod = int(new_response.split("-- mod-version:",1)[1].split(" ")[0].encode())
        except:
          mod = int(new_response.split("-- mod-version:",1)[1].split("\n").encode())
      except:
        mod = 99

    version = ""
    try:
      version = "" + new_response.split("-- lite-xl ",1)[1].split("\n")[0].encode().decode()
    except:
      ""
    return version, patch, mod

# To receive a starting file for getting mod and lite-xl version
def get_info(name, url):
  new_url = url
  try:
    new_url.index("/blob/")
  except:
    new_url += "/blob/"
  try:
    new_url.index("?raw=1")
    return url
  except:
    ""
  for branch in branches:
    h = httplib2.Http()
    if int(h.request(new_url + branch + "/init.xl.lua?raw=1", 'HEAD')[0]['status']) == 200:
      return new_url + branch + "/init.xl.lua?raw=1"
    elif int(h.request(new_url + branch + "/init.lua?raw=1", 'HEAD')[0]['status']) == 200:
      return new_url + branch + "/init.lua?raw=1"
    elif int(h.request(new_url + branch + "/" + name + "_xl.lua?raw=1", 'HEAD')[0]['status']) == 200:
      return new_url + branch + "/" + name + "_xl.lua?raw=1"
    elif int(h.request(new_url + branch + "/" + name + ".lua?raw=1", 'HEAD')[0]['status']) == 200:
      return new_url + branch + "/" + name + ".lua?raw=1"
    else:
      return url

def create_json_object(line, repo, etype):
  name = ""
  author = ""
  description = ""
  mod = 0
  patch = ""
  sep = ""
  version = ""
  url = ""
  try:
    name = get_name(line)
    if name == "make_preview_image.lua":
        throw("Error")
    url = get_url(line, HEAD + "/" + repo + "/blob/master" )
    author = get_author(url)
    description = get_description(line, etype, name)
    special_url = get_info(name, url)
    version,patch,mod = get_version_patch_mod(url,special_url, etype)
    sep = is_sep(url)
    print(name)
    print(url)
  except:
   throw("Error")

  extension = {
    "name": name,
    "author": author,
    "description": description,
    "url": url,
    "lite_xl_version": version,
    "mod": mod,
    "patch": patch,
    "sep": sep
  }
  return True, extension

def json_list(list,readme, etype, repo):
  for line in readme:
    try:
      success, extension = create_json_object(line, repo, etype)
    except:
      continue
    if success:
      try:
        list.append(extension)
      except:
        continue
    else:
      continue
  return list


def write_to_json(list):
  with open("extensions_tmp.json", "w+") as file:
      file.write(json.dumps(list, indent=2))


def read_readme():
  list = []
  for i in range(0, 4, 2):
      response = requests.get(HEAD + "/" + repos[i + 1] + "/blob/master/README.md?raw=1")
      content = response.text
      readme = content.split("\n")
      list = json_list(list, readme, repos[i], repos[i + 1])
  write_to_json(list)

if __name__ == "__main__":
  read_readme()
