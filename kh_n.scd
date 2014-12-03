(
s.options.numOutputBusChannels=10;
s.waitForBoot({
    var timses;
	~bpm=125;
	~linedur = 15/~bpm;
	// line impulse bus
	~ping = Bus.control();

	// bar impulse bus
	~reset = Bus.control();

	// number of midi controls
	~ncontrols=24 + (32*3);

	// control busses
	~controls = {Bus.control()}!(~ncontrols);
	~respondershift = 0;
	//midi responder
	CCResponder({|s,ch,c,v| ~controls[c].set(v/128); ~writecond = true},nil,1,{|c| c < 24});
	CCResponder({|s,ch,c,v| ~controls[c + (~respondershift*32)].set(v/128); ~writecond = true},nil,1,{|c| c >= 24});

	// midi control lagger
	~control = {|n| Lag.kr(In.kr(~controls[n]),0.1)};

	//envelope shear
	timses = {|n,tsig| Sweep.kr(tsig,0.1 + (10/~control.value(n).linexp(0,1,1,20)) )};


	// sound groover
	~linedelay = {|c,sig| DelayL.ar(sig,0.1*~linedur,~linedur*0.1*c)};

    ~lines =8;

	~mainmix = Bus.audio(s,2);
	// buffer recording
	~mainclip = Buffer.alloc(s, Server.local.sampleRate * ~lines * ~linedur,2);

	// sound output for recording

	// file name definition
	~directory = "bretonne/clips";
	~clipname = "runz";
	~version = 1;
	~name = {~directory ++ "/" ++ ~clipname ++ "_" ++ ~version};

	// reset synchronized recorder
	~notwriting = Bus.control();



	SynthDef(\outer,{
		arg inbus,outbus;
		var sig = In.ar(inbus,2);
		Out.ar(outbus,sig);
	}).send;
	// kick sound
	SynthDef(\kick,{
		var env2,sig,env,noise,envnoise;
		var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,3,1,1);
		env2 = IEnvGen.ar(Env.perc(0.0,2,curve:-6),timses.value(5,tsig),~control.value(3),~control.value(4));
		env = IEnvGen.kr(Env.perc(0.03,2,curve:-6),timses.value(2,tsig));
		sig = SinOsc.ar(1.5*env2*(~control.value(6).linexp(0,1,40,300)) , 0)*(env);
		sig = Mix.ar(sig);
		sig = ~linedelay.value(~control.value(1),sig)*~control.value(0);
		Out.ar(~mainmix,Pan2.ar(sig));

	}).send;

	// zz sound
	SynthDef(\zz,{|w,a|
		var env2,sig,env,noise,envnoise,del,del2,del3,del4;
		var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,3,1,(w%2) * 2 + 1);

		sig= WhiteNoise.ar();
		env = IEnvGen.kr(Env.perc(0,0.4,curve:-3),timses.value(10,tsig));
		sig = RHPF.ar(sig*env,~control.value(11).linexp(0,1,3000,20000));
		sig = ~linedelay.value(~control.value(9),sig)*~control.value(8);
		Out.ar(~mainmix,Pan2.ar(a*sig));
	}).send;

	// snare sound
	SynthDef(\snare,{
		var env2,sig,env,noise,envnoise,sines,envsines,tri,envtri;
		var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,7,1,5);
		var vib = LFTri.ar(20,0,0.4,0.8);
		noise = vib * LPF.ar(WhiteNoise.ar(),~control.value(23).linexp(0,1,300,20000));
		sines = Mix.ar(SinOsc.ar([180,330]));
		tri = Mix.ar(FreqShift.ar(LFTri.ar(111) ,[175,224]));
		envsines = IEnvGen.kr(Env.perc,timses.value(18,tsig));
		envtri = ~control.value(21) * IEnvGen.kr(Env.perc,timses.value(19,tsig));
		envnoise = ~control.value(22) * IEnvGen.kr(Env.perc,timses.value(20,tsig));

		sig = ((envsines*sines)+(envtri * tri)+(noise*envnoise));

		sig = ~linedelay.value(~control.value(17),sig)*~control.value(16);
		Out.ar(~mainmix,Pan2.ar(sig));

	}).send;

	SynthDef(\repeat,{
		arg control,outbus,inrecord;
		var cntrl = {|n| Lag.kr(In.kr((control + n)),0.1)};
		//var qcntrl = {|n,q| (cntrl.(n)*q).fl};
		var dur = cntrl.value(2);
		var nstart = cntrl.value(0)* BufDur.kr(~mainclip);
		var where = cntrl.value(1)*BufFrames.kr(~mainclip);
		var rate,sig3,env2,sig,sig2,env,noise,envnoise,sines,envsines,tri,envtri,start;
		start = DelayL.kr(In.kr(~reset),BufDur.kr(~mainclip),nstart);

		rate = cntrl.value(4) * ~linedur * ~lines;
		sines = Phasor.kr(start,1/rate/ControlRate.ir,-0.5,0.5,-0.0001);

		env2 = EnvGen.ar(Env.linen(0.001,(rate-0.02)*cntrl.value(6),0.01),sines);

		//var stop = Stepper.kr(In.kr(~ping),In.kr(~reset),0,7,1,nstop + nstart);
		env = EnvGen.ar(Env.linen(0.001,dur,0.01),start);
		sig = PlayBuf.ar(2,inrecord,cntrl.value(5)*2,sines,where,1)*env*env2;
		Out.ar(outbus,sig*cntrl.value(3));
	}).send;


(

SynthDef(\recorder,{
		arg outbus=0,buf=1;
		var trig = In.kr(~reset);
	var notWriting = ToggleFF.kr(In.kr(~reset));
		var env = EnvGen.ar(Env.linen(0.001,~lines * ~linedur-0.003,0.001),trig);
		RecordBuf.ar(env*In.ar(outbus,2),buf,run:notWriting,loop:0,trigger:trig);
	SendTrig.kr(not(notWriting),outbus);
	}).send;

);

	// load the file or set all param to 0 for all parameter sets
	~mo = MIDIOut(0).connect(1); //feedback for channel 1
	~mo.latency = 0;

	~setversion = {|n|
		~version = n;
		File.exists(~name.value() ++ ".data").if(
			{~controls[0].setnSynchronous(Object.readArchive(~name.value() ++ ".data"))},
			{~controls[0].setnSynchronous(Array.fill(~ncontrols,{0}))});
		~controls[0].getnSynchronous(24).do({|v,c| ~mo.control(1,c,v*128)});
		~controls[24 + (~respondershift*32)].getnSynchronous(32).do(
			{|v,c| ~mo.control(1,c+ 24,v*128)});
	};
	~copyversion = {|n|
		~version = n;
	};

	~setversion.value(1);
	~writecond = true;

~setrepeater = {|i|
	~respondershift = i;
	~setversion.value(~version);
}

});
)

~setrepeater = {|i|
	~respondershift = i;
	~setversion.value(~version);
}

	~setversion.value(1);
~setrepeater.value(1);


// record mainmix
(
fork {
			inf.do {
				~writecond.if(
					{
					~writecond = false;
					~controls[0].getnSynchronous(~ncontrols).writeArchive(~name.value() ++ ".data");
					(~name.value() ++ " written").postln
					}
					,
					{1.wait}
				)
			}

		};

Synth.tail(nil,\recorder,[\outbus,~mainmix,\buf,~mainclip]);
OSCFunc({
	arg msg, time;
	if(msg[2] == ~mainmix.index,
		{  ~mainclip.write(~name.value() ++ ".main" ++ ".wav" ,"WAV")}
		,{});
},'/tr', s.addr);

{Out.kr(~ping,Impulse.kr(1/~linedur))}.play;
{DelayL.kr(Out.kr(~reset,PulseDivider.kr(In.kr(~ping),~lines)),0.1,0.05)}.play;
Synth(\kick);
Synth(\zz,[\w,1,\a,1]);
Synth(\zz,[\w,0,\a,0.03]);
Synth(\snare);
Synth.tail(nil,\outer,[\inbus,~mainmix,\outbus,0]);

3.do {|j|

	var outbus = Bus.audio(s,2);
	var buf = Buffer.alloc(s, Server.local.sampleRate * ~lines * ~linedur, 2);

	4.do{|i| Synth(\repeat,[\control,~controls[24 + (32*j) + (i * 8)].index,
		\outbus,outbus,\inrecord,~mainclip])};

	Synth.tail(nil,\outer,[\inbus,outbus,\outbus,2 * j + 2]);
	Synth.tail(nil,\recorder,[\outbus,outbus,\buf,buf]);
	OSCFunc({
		arg msg, time;
		if(msg[2] == outbus.index,
			{  msg.postln;buf.write(~name.value() ++ "." ++ j ++ ".wav" ,"WAV")}
			,{});
	},'/tr', s.addr);

}
)
