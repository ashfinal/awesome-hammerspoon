local obj={}
obj.__index = obj

obj.name = "justNote"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"

-- Internal function used to find our location, so we know where to load files from
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

obj.spoonPath = script_path()

-- Define the source's overview. A unique `keyword` key should exist, so this source can be found.
obj.overview = {text="Type n ⇥ to Note something.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/justnote.png"), keyword="n"}
-- Define the notice when a long-time request is being executed. It could be `nil`.
obj.notice = nil
-- Define the hotkeys, which will be enabled/disabled automatically. You need to add your keybindings into this table manually.
obj.hotkeys = {}

local function justNoteRequest()
    local note_history = hs.settings.get("just.another.note") or {}
    if #note_history == 0 then
        local chooser_data = {{text="Write something and press Enter.", subText="Your notes is automatically saved, selected item will be erased.", image=hs.image.imageFromPath(obj.spoonPath .. "/resources/justnote.png")}}
        return chooser_data
    else
        local chooser_data = hs.fnutils.imap(note_history, function(item)
            return {uuid=item.uuid, text=item.content, subText=item.ctime, image=hs.image.imageFromPath(obj.spoonPath .. "/resources/justnote.png"), output="noteremove", arg=item.uuid}
        end)
        return chooser_data
    end
end
-- Define the function which will be called when the `keyword` triggers a new source. The returned value is a table. Read more: http://www.hammerspoon.org/docs/hs.chooser.html#choices
obj.init_func = justNoteRequest
-- Insert a friendly tip at the head so users know what to do next.
obj.description = nil
-- As the user is typing, the callback function will be called for every keypress. The returned value is a table.

local function isInNoteHistory(value, tbl)
    for idx,val in pairs(tbl) do
        if val.uuid == value then
            return true
        end
    end
    return false
end

local function justNoteStore()
    if spoon.HSearch then
        local querystr = string.gsub(spoon.HSearch.chooser:query(), "%s+$", "")
        if string.len(querystr) > 0 then
            local query_hash = hs.hash.SHA1(querystr)
            local note_history = hs.settings.get("just.another.note") or {}
            if not isInNoteHistory(query_hash, note_history) then
                table.insert(note_history, {uuid=query_hash, ctime="Created at "..os.date(), content=querystr})
                hs.settings.set("just.another.note", note_history)
            end
        end
    end
end

local store_trigger = hs.hotkey.new("", "return", nil, function()
    justNoteStore()
    if spoon.HSearch then
        local chooser_data = justNoteRequest()
        spoon.HSearch.chooser:choices(chooser_data)
        spoon.HSearch.chooser:query("")
    end
end)
table.insert(obj.hotkeys, store_trigger)

obj.callback = nil

-- Define a new output type
local function removeNote(arg)
    local note_history = hs.settings.get("just.another.note") or {}
    for idx,val in pairs(note_history) do
        if val.uuid == arg then
            table.remove(note_history, idx)
            hs.settings.set("just.another.note", note_history)
        end
        local chooser_data = justNoteRequest()
        if spoon.HSearch then
            spoon.HSearch.chooser:choices(chooser_data)
        end
    end
end
obj.new_output = {
    name = "noteremove",
    func = removeNote
}


return obj
