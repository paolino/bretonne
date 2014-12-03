(
// load all the files in /my/sound/files with a .wav extension and stick them in an array called ~buffers
~buffers = SoundFile.collectIntoBuffers("bretonne/clips/tunz_*.wav");
)


(
    var timses;
	~bpm=125;
	~linedur = 15/~bpm;
	// line impulse bus
	~ping = Bus.control();

	// bar impulse bus
	~reset = Bus.control();

	// number of midi controls
	~ncontrols=56;

	// control busses
	~controls = {Bus.control()}!(~ncontrols);

	//midi responder

CCResponder({|s,ch,c,v| ~controls[c-81].set(v/128); ~writecond = true},nil,1,{|c| c > 80 && (c < 128)});
	// midi control lagger
	~control = {|n| Lag.kr(In.kr(~controls[n]),0.1)};

	// sound groover
	~linedelay = {|c,sig| DelayL.ar(sig,0.1*~linedur,~linedur*0.1*c)};

    ~lines = 16;

	// sound output for recording
	~mixer = Bus.audio(s,2);
)

(
~buffers = SoundFile.collectIntoBuffers("bretonne/clips/tunz_*.wav");
CCResponder({|s,ch,c,v| ~controls[c-81].set(v/128); ~writecond = true},nil,1,{|c| c > 80 && (c < 128)});

~resetter.free;
~resetter = {Out.kr(~reset,Impulse.kr(1/~lines/~linedur))}.play
)
(

		~rs.do({|r| r.free});
		~rs = 8.collect {|i|
			{Out.ar(0,~control.(i) * PlayBuf.ar(2,~buffers[i],trigger:In.kr(~reset),loop:1))}.play
		}
)

	~rs
~controls[0].scope()