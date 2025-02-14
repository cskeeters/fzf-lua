local libuv = require("fzf-lua.libuv")


describe("Testing libuv module", function()
  it("is_escaped (posix)", function()
    assert.is.False(libuv.is_escaped([[]], false))
    assert.is.True(libuv.is_escaped([[""]], false))
    assert.is.True(libuv.is_escaped([['']], false))
    assert.is.True(libuv.is_escaped([['foo']], false))
  end)

  it("is_escaped (win)", function()
    assert.is.False(libuv.is_escaped([[]], true))
    assert.is.True(libuv.is_escaped([[""]], true))
    assert.is.True(libuv.is_escaped([[^"^"]], true))
    assert.is.False(libuv.is_escaped([['']], true))
  end)

  it("shellescape (win bslash)", function()
    assert.are.same(libuv.shellescape([[]], 1), [[""]])
    assert.are.same(libuv.shellescape([[^]], 1), [["^"]])
    assert.are.same(libuv.shellescape([[""]], 1), [["\"\""]])
    assert.are.same(libuv.shellescape([["^"]], 1), [["\"^\""]])
    assert.are.same(libuv.shellescape([[foo]], 1), [["foo"]])
    assert.are.same(libuv.shellescape([["foo"]], 1), [["\"foo\""]])
    assert.are.same(libuv.shellescape([["foo"bar"]], 1), [["\"foo\"bar\""]])
    assert.are.same(libuv.shellescape([[foo"bar]], 1), [["foo\"bar"]])
    assert.are.same(libuv.shellescape([[foo""bar]], 1), [["foo\"\"bar"]])
    assert.are.same(libuv.shellescape([["foo\"bar"]], 1), [["\"foo\\\"bar\""]])
    assert.are.same(libuv.shellescape([[foo\]], 1), [["foo\\"]])
    assert.are.same(libuv.shellescape([[foo\\]], 1), [["foo\\\\"]])
    assert.are.same(libuv.shellescape([[foo\^]], 1), [["foo\^"]])
    assert.are.same(libuv.shellescape([[foo\\\\]], 1), [["foo\\\\\\\\"]])
    assert.are.same(libuv.shellescape([[foo\"]], 1), [["foo\\\""]])
    assert.are.same(libuv.shellescape([["foo\"]], 1), [["\"foo\\\""]])
    assert.are.same(libuv.shellescape([["foo\""]], 1), [["\"foo\\\"\""]])
    assert.are.same(libuv.shellescape([[foo\bar]], 1), [["foo\bar"]])
    assert.are.same(libuv.shellescape([[foo\\bar]], 1), [["foo\\bar"]])
    assert.are.same(libuv.shellescape([[foo\\"bar]], 1), [["foo\\\\\"bar"]])
    assert.are.same(libuv.shellescape([[foo\\\"bar]], 1), [["foo\\\\\\\"bar"]])
  end)

  it("shellescape (win caret)", function()
    assert.are.same(libuv.shellescape([[]], 2), [[^"^"]])
    assert.are.same(libuv.shellescape([["]], 2), [[^"\^"^"]])
    assert.are.same(libuv.shellescape([[^"]], 2), [[^"^^\^"^"]])
    assert.are.same(libuv.shellescape([[\"]], 2), [[^"\\\^"^"]])
    assert.are.same(libuv.shellescape([[\^"]], 2), [[^"^^\\\^"^"]])
    assert.are.same(libuv.shellescape([[^"^"]], 2), [[^"^^\^"^^\^"^"]])
    assert.are.same(libuv.shellescape([[__^^"^"__]], 2), [[^"__^^^^\^"^^\^"__^"]])
    assert.are.same(libuv.shellescape([[__!^^"^"__]], 2),
      -- 1st: ^"_^!^^^^\^"^^\^"_^"
      -- 2nd: ^"_^^^!^^^^^^^^^^\\\^"^^^^^^\\\^"_^"
      [[^"__^^^!^^^^^^^^^^\\\^"^^^^^^\\\^"__^"]])
    assert.are.same(libuv.shellescape([[__^^^^\^"^^\^"__]], 2),
      [[^"__^^^^^^^^^^\\\^"^^^^^^\\\^"__^"]])
    assert.are.same(libuv.shellescape([[^]], 2), [[^"^^^"]])
    assert.are.same(libuv.shellescape([[^^]], 2), [[^"^^^^^"]])
    assert.are.same(libuv.shellescape([[^^^]], 2), [[^"^^^^^^^"]])
    assert.are.same(libuv.shellescape([[^!^]], 2), [[^"^^^^^^^!^^^^^"]])
    assert.are.same(libuv.shellescape([[!^"]], 2),
      -- 1st inner: ^!^^\^"
      -- 2nd inner: ^^^!^^^^^^\\\^"
      [[^"^^^!^^^^^^\\\^"^"]])
    assert.are.same(libuv.shellescape([[!\"]], 2), [[^"^^^!^^\\\\\\\^"^"]])
    assert.are.same(libuv.shellescape([[!\^"]], 2), [[^"^^^!^^^^^^\\\\\\\^"^"]])
    assert.are.same(libuv.shellescape([[()%^"<>&|]], 2), [[^"^(^)^%^^\^"^<^>^&^|^"]])
    assert.are.same(libuv.shellescape([[()%^"<>&|!]], 2),
      -- 1st inner: ^(^)^%^^\^"^<^>^&^|^!
      -- 2nd inner: ^^^(^^^)^^^%^^^^^^\^"^^^<^^^>^^^&^^^|^^^!
      [[^"^^^(^^^)^^^%^^^^^^\\\^"^^^<^^^>^^^&^^^|^^^!^"]])
    assert.are.same(libuv.shellescape([[foo]], 2), [[^"foo^"]])
    assert.are.same(libuv.shellescape([[foo\]], 2), [[^"foo\\^"]])
    assert.are.same(libuv.shellescape([[foo^]], 2), [[^"foo^^^"]])
    assert.are.same(libuv.shellescape([[foo\\]], 2), [[^"foo\\\\^"]])
    assert.are.same(libuv.shellescape([[foo\\\]], 2), [[^"foo\\\\\\^"]])
    assert.are.same(libuv.shellescape([[foo\\\\]], 2), [[^"foo\\\\\\\\^"]])
    assert.are.same(libuv.shellescape([[f!oo]], 2), [[^"f^^^!oo^"]])
    assert.are.same(libuv.shellescape([[^"foo^"]], 2), [[^"^^\^"foo^^\^"^"]])
    assert.are.same(libuv.shellescape([[\^"foo\^"]], 2), [[^"^^\\\^"foo^^\\\^"^"]])
    assert.are.same(libuv.shellescape([[foo""bar]], 2), [[^"foo\^"\^"bar^"]])
    assert.are.same(libuv.shellescape([[foo^"^"bar]], 2), [[^"foo^^\^"^^\^"bar^"]])
    assert.are.same(libuv.shellescape([["foo\"bar"]], 2), [[^"\^"foo\\\^"bar\^"^"]])
    assert.are.same(libuv.shellescape([[foo\^"]], 2), [[^"foo^^\\\^"^"]])
    assert.are.same(libuv.shellescape([[foo\"]], 2), [[^"foo\\\^"^"]])
    assert.are.same(libuv.shellescape([[^"foo\^"^"]], 2), [[^"^^\^"foo^^\\\^"^^\^"^"]])
    assert.are.same(libuv.shellescape([[foo\"bar]], 2), [[^"foo\\\^"bar^"]])
    assert.are.same(libuv.shellescape([[foo\\"bar]], 2), [[^"foo\\\\\^"bar^"]])
    assert.are.same(libuv.shellescape([[foo\\^^"bar]], 2), [[^"foo\\^^^^\^"bar^"]])
    assert.are.same(libuv.shellescape([[foo\\\^^^"]], 2), [[^"foo\\\^^^^^^\^"^"]])
  end)

  it("escape {q} (win)", function()
    assert.are.same(libuv.escape_fzf([[]], true), [[]])
    assert.are.same(libuv.escape_fzf([[\]], true), [[\]])
    assert.are.same(libuv.escape_fzf([[\\]], true), [[\\]])
    assert.are.same(libuv.escape_fzf([[foo]], true), [[foo]])
    assert.are.same(libuv.escape_fzf([[\foo]], true), [[\\foo]])
    assert.are.same(libuv.escape_fzf([[\\foo]], true), [[\\\\foo]])
    assert.are.same(libuv.escape_fzf([[\\\foo]], true), [[\\\\\\foo]])
    assert.are.same(libuv.escape_fzf([[\\\\foo]], true), [[\\\\\\\\foo]])
    assert.are.same(libuv.escape_fzf([[foo\]], true), [[foo\]])
    assert.are.same(libuv.escape_fzf([[foo\\]], true), [[foo\\]])
  end)

  it("unescape {q} (win)", function()
    assert.are.same(libuv.unescape_fzf([[]], true), [[]])
    assert.are.same(libuv.unescape_fzf([[\]], true), [[\]])
    assert.are.same(libuv.unescape_fzf([[\\]], true), [[\\]])
    assert.are.same(libuv.unescape_fzf([[foo]], true), [[foo]])
    assert.are.same(libuv.unescape_fzf([[\foo]], true), [[\foo]])
    assert.are.same(libuv.unescape_fzf([[\\foo]], true), [[\foo]])
    assert.are.same(libuv.unescape_fzf([[\\\foo]], true), [[\foo]])
    assert.are.same(libuv.unescape_fzf([[\\\\foo]], true), [[\\foo]])
    assert.are.same(libuv.unescape_fzf([[foo\]], true), [[foo\]])
    assert.are.same(libuv.unescape_fzf([[foo\\]], true), [[foo\\]])
  end)
end)
