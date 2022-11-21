# Profiler Plugin

Profiling is mainly the runtime analysis of a program performance by counting
the calls and duration for the various routines executed thru the lifecycle
of the application. For more information view the [wikipedia] article.

This plugin adds the ability to profile function calls while running Lite XL,
becoming easier to investigate performance related issues and pinpoint what
could be causing them. It integrates the [lua-profiler] which provides
the functionality we need.

## Usage

Open Lite XL and access the command palette by pressing `ctrl+shift+p` and
search for `profiler`. The command `Profiler: Toggle` will be shown to let you
start or stop the profiler. You should start the profiler before triggering
the events that are causing any performance issues.

![command](https://user-images.githubusercontent.com/1702572/202113672-6ba593d9-03be-4462-9e82-e3339cf2722f.png)

> **Note:** Starting the profiler will make the editor slower since it is
> now accumulating metrics about every function call. Do not worry, this is
> expected and shouldn't affect the end result, just be patience because
> everything will be slower.

There may be some situations when you would like to enable the profiler
early on the startup process so we provided a configuration option for that.
Also the profiler output is saved to a log file for easy sharing, its default
path is also configurable as shown below:

![settings](https://user-images.githubusercontent.com/1702572/202113713-7e932b4f-3283-42e6-af92-a1aa9ad09bde.png)

> **Note:** since the profiler is not part of the core, but a plugin, it will
> only start accumulating metrics once the plugin is loaded. The `priority`
> tag of the profiler plugin was set to `0` to make it one of the first
> plugins to start.

Once you have profiled enough you can execute the `Profiler: Toggle` command
to stop it, the log will be automatically open with the collected metrics
as shown below:

![metrics](https://user-images.githubusercontent.com/1702572/202113736-ef8d550c-130e-4372-b66c-694ee5f4c5c0.png)

You can send Lite XL developers the output of `profiler.log` so it can be
more easily diagnosed what could be causing any issue.

[wikipedia]: https://en.wikipedia.org/wiki/Profiling_(computer_programming)
[lua-profiler]: https://github.com/charlesmallah/lua-profiler
