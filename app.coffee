t_sharps = ["C","C","D","D","E","F","F","G","G","A","A","B"]
t_flats = ["C","D","D","E","E","F","G","G","A","A","B","B"]

f_tone = {
    "c" : 0,"C" : 0,"b#" : 0,"B#" : 0,
    "C#" : 1,"c#" : 1,"db" : 1,"Db" : 1,
    "D" : 2, "d": 2,
    "D#" : 3,"d#" : 3,"eb" : 3, "Eb" : 3,
    "E" : 4,"e" : 4, "Fb" : 4, "fb" : 4,
    "F" : 5, "f" : 5, "E#" : 5, "e#" :5,
    "F#" : 6, "f#" : 6, "Gb" : 6, "gb" : 6,
    "G" : 7, "g" : 7,
    "Ab" : 8, "ab" : 8, "G#" : 8, "g#" : 8,
    "A" : 9, "a" : 9,
    "Bb" : 10, "bb" : 10, "A#" : 10,"a#" : 10,
    "B" :11, "b" : 11, "Cb" : 11, "cb":11
    }

l_songs = db_songs
l_cur = 0

fillSongs = (songlist) ->
    str = ""
    i = 0
    for song in songlist
        str += "<button id='btn#{i}' type='button'>#{song.name}</button>"
        i++
    $$("songlist").innerHTML = str
    for n in [0..i-1]
        f = () ->
            q = n
            btn = $$("btn#{q}")
            btn.num_ = q 
            btn.addEventListener 'click', () ->
                loadSong l_songs[q]
                l_cur = q
        f()
    undefined

    

$$ = (x) -> document.getElementById (x)

getTone = () ->
    str = ($$("tone").value).trim() 
    if str of f_tone
        f_tone[str]
    else
        0

getAlterationStyle = () ->
    str = $$("tone").value
    if /#/.test(str) or getTone() == 11
        false
    else if /b/.test(str) or getTone() == 5
        true
    else
        false

isAltered = (absolute_tone) ->
    absolute_tone = absolute_tone %% 12
    if absolute_tone < 5
        absolute_tone %% 2 == 1
    else
        absolute_tone %% 2 == 0

encodeChord = (chordstr, base_tone, flats) ->
    p_suffix = "b"
    namer = t_flats
    
    if not flats
        namer = t_sharps
        p_suffix = "#"
    
    if chordstr.length < 2
        ""
    else
        chord = parseInt ( chordstr.slice 0,2 )
        chord = (chord + base_tone ) %% 12
        
        suffix = ""
        
        if isAltered chord 
            suffix = p_suffix
        
        barre_pos = chordstr.indexOf("/")
        
        if  barre_pos >= 0 and barre_pos < chordstr.length - 2
            chordi = parseInt ( chordstr.slice barre_pos+1,barre_pos+3)
            chordi = (chordi + base_tone ) %% 12
            suffixi = ""
            
            if isAltered chordi 
                suffixi = p_suffix
            
            return namer[chord]+suffix+(chordstr.slice 2,barre_pos+1)+
                    namer[chordi]+suffixi
        else
            return namer[chord]+suffix+(chordstr.slice 2)


parseChunk = (chordlist, lyricline, anchors, base_tone, flats) ->
    len_line = Math.min(chordlist.length,anchors.length)
    chords = ""
    lyrics = ""
    if anchors[0] > 0
        chords += " ".repeat(anchors[0])
        lyrics += lyricline.slice(0, anchors[0])
    
    for i in [0...len_line]
        cpadding = ""
        lpadding = ""
        chordstr = encodeChord(chordlist[i],base_tone, flats)
        lyric_len = (if anchors[i+1]? then anchors[i+1] else lyricline.length) - anchors[i]
        last_char = lyricline[anchors[i] + lyric_len - 1]
        padding_size = chordstr.length - lyric_len
        if padding_size < 0
            cpadding = " ".repeat(0 - padding_size)
        
        if padding_size == 0
            cpadding = " "
            if /\s/.test(last_char)
                lpadding = " "
            else lpadding = "_"
        
        if padding_size > 0
            cpadding = " "
            if /\s/.test(last_char)
                lpadding = " ".repeat(padding_size+1)
            else lpadding = "_".repeat(padding_size+1)
        chords += chordstr + cpadding
        lyrics += lyricline.slice(anchors[i],anchors[i]+lyric_len) + lpadding
    [chords, lyrics]
    

parseSection = (section, base_tone, flats) ->
    text = "<h1>#{section.title}</h1>"
    len_sect = Math.min(section.anchors.length,section.chords.length)
    for i in [0...len_sect]
        [chord, lyrics] = 
            parseChunk(section.chords[i],section.lyrics[i], section.anchors[i], base_tone, flats)
        text += "<b>#{chord}</b>\n#{lyrics}\n"
    text
    
clicks = 1

loadSection = (section,key, flats) ->
    html = $.parseHTML("<li class='flex-item'><pre class='p1'>" +
            parseSection(section,key, flats)+"</pre></li>")
    $("#SONG").append html
    
loadSong = (song_data) ->
    if song_data
    else return
    if song_data.flats == undefined
        if (isAltered song_data.tone and song_data.tone != 6) or song_data.tone == 5
            song_data.flats = true
        else 
            song_data.flats = false
    $("#SONG").empty()
    loadSection section, song_data.tone, song_data.flats for section in song_data.sections

$(document).ready( () ->
     
    $$("cycle").addEventListener 'click', () ->
        $("#SONG").children().first().animate {height : 0, marginTop :0, marginBottom: 0, padding: 0},900, () ->
            $("#SONG").append($(this).detach().css("height","").css("margin-top","5px").css("margin-bottom","5px"))
    
    $$("tone_button").addEventListener 'click', () ->
        l_songs[l_cur].tone = getTone()
        l_songs[l_cur].flats = getAlterationStyle()
        loadSong l_songs[l_cur]

    
    $$("tone_form").addEventListener 'submit', (e) ->
        e.preventDefault()
        l_songs[l_cur].tone = getTone()
        l_songs[l_cur].flats = getAlterationStyle()
        loadSong l_songs[l_cur]
        return false
    
    fillSongs db_songs
);


    
