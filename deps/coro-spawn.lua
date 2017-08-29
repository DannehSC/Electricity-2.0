--[[lit-meta
  name = "creationix/coro-spawn"
  version = "3.0.0"
  dependencies = {
    "creationix/coro-channel@3.0.0"
  }
  homepage = "https://github.com/luvit/lit/blob/master/deps/coro-spawn.lua"
  description = "An coro style interface to child processes."
  tags = {"coro", "spawn", "child", "process"}
  license = "MIT"
  author = { name = "Tim Caswell" }
]]

local uv = require('uv')
local channel = require('coro-channel')
local wrapRead = channel.wrapRead
local wrapWrite = channel.wrapWrite

return function (path, options)
  local stdin, stdout, stderr
  local stdio = options.stdio

  -- If no custom stdio is passed in, create pipes for stdin, stdout, stderr.
  if not stdio then
    stdio = {true, true, true}
    options.stdio = stdio
  end

  if stdio then
    if stdio[1] == true then
      stdin = uv.new_pipe(false)
      stdio[1] = stdin
    end
   if stdio[2] == true then
      stdout = uv.new_pipe(false)
      stdio[2] = stdout
    end
    if stdio[3] == true then
      stderr = uv.new_pipe(false)
      stdio[3] = stderr
    end
  end

  local exitThread, exitCode, exitSignal

  local function onExit(code, signal)
    exitCode = code
    exitSignal = signal
    if not exitThread then return end
    local thread = exitThread
    exitThread = nil
    return assert(coroutine.resume(thread, code, signal))
  end

  local handle, pid = uv.spawn(path, options, onExit)

  -- If the process has exited already, return the cached result.
  -- Otherwise, wait for it to exit and return the result.
  local function waitExit()
    if exitCode then
      return exitCode, exitSignal
    end
    assert(not exitThread, "Already waiting on exit")
    exitThread = coroutine.running()
    return coroutine.yield()
  end

  local result = {
    handle = handle,
    pid = pid,
    waitExit = waitExit
  }

  if stdin then
    result.stdin = {
      handle = stdin,
      write = wrapWrite(stdin)
    }
  end

  if stdout then
    result.stdout = {
      handle = stdout,
      read = wrapRead(stdout)
    }
  end

  if stderr then
    result.stderr = {
      handle = stderr,
      read = wrapRead(stderr)
    }
  end

  return result

end
