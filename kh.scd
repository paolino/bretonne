//global setup
/*

~makeNRPNResp = { |parmnum = 0, action|
     var    list = #[99, 98, 6, 38],
         seq = Pseq(list, 1).asStream,
         incomingNum = 0, incomingVal = 0;
     CCResponder({ |src, chan, num, val|
         if(num == seq.next) {
             switch(num)
                 { 99} { incomingNum = incomingNum | (val << 7) }
                 { 98} { incomingNum = incomingNum | val }
                 { 6 } { incomingVal = incomingVal | (val << 7) }
                 { 38 } {
                     incomingVal = incomingVal | val;
                     if(incomingNum == parmnum) {
                         action.value(incomingVal, incomingNum);
                     };
                     incomingNum = incomingVal = 0;
                     seq.reset;
                 }
         } {
             seq.reset
         };
     }, num: list);
};
*/

/*
	[0,1,8,9,16,17,24,25].do{
		|i| ~makeNRPNResp.(i, {|v,c| ~controls[24 + i].set(v/1024); ~writecond=true;});
	};
    */
(

s.waitForBoot({
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

	CCResponder({|s,ch,c,v| ~controls[c].set(v/128); ~writecond = true},nil,1,{|c| c < 56});
	// midi control lagger
	~control = {|n| Lag.kr(In.kr(~controls[n]),0.1)};

	timses = {|n,tsig| Sweep.kr(tsig,0.1 + (10/~control.value(n).linexp(0,1,1,20)) )};

	// sound groover
	~linedelay = {|c,sig| DelayL.ar(sig,0.1*~linedur,~linedur*0.1*c)};

    ~lines = 16;

	// sound output for recording
	~mixer = Bus.audio(s,2);

	// buffer recording
	~record = Buffer.alloc(s, Server.local.sampleRate * ~lines * ~linedur, 2,18);

	// sound output for recording
	~repeatout = Bus.audio(s,2);

	~recordmixed = Buffer.alloc(s, Server.local.sampleRate * ~lines * ~linedur, 2,18);

	// buffer recording
	~repeatrecord = Buffer.alloc(s, Server.local.sampleRate * ~lines * ~linedur, 2,18);

	// file name definition
	~directory = "bretonne/clips";
	~clipname = "tunz";
	~version = 1;
	~name = {~directory ++ "/" ++ ~clipname ++ "_" ++ ~version};

	// reset synchronized recorder
	SynthDef(\recorder,{
		var trig = In.kr(~reset);
		var env = EnvGen.ar(Env.linen(0.001,~lines * ~linedur-0.003,0.001),trig);
		RecordBuf.ar(env*In.ar(~mixer,2),~record,run:SetResetFF.kr(trig),loop:0);
		RecordBuf.ar(env*In.ar(~mixer,2),~recordmixed,run:SetResetFF.kr(trig),loop:0,doneAction:2)

	}).send;
	SynthDef(\repeatrecorder,{
		var trig = In.kr(~reset);
		var env = EnvGen.ar(Env.linen(0.001,~lines * ~linedur-0.003,0.001),trig);
		RecordBuf.ar(env*In.ar(~repeatout,2),~repeatrecord,run:SetResetFF.kr(trig),loop:0);
		RecordBuf.ar(env*In.ar(~repeatout,2),~recordmixed,recLevel:1,preLevel:1,run:SetResetFF.kr(trig),loop:0,doneAction:2)

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
		Out.ar(~mixer,Pan2.ar(sig));

	}).send;

	// zz sound
	SynthDef(\zz,{|w,a|
		var env2,sig,env,noise,envnoise,del,del2,del3,del4;
		var tsig = Stepper.kr(In.kr(~ping),In.kr(~reset),0,3,1,(w%2) * 2 + 1);

		sig= WhiteNoise.ar();
		env = IEnvGen.kr(Env.perc(0,0.4,curve:-3),timses.value(10,tsig));
		sig = RHPF.ar(sig*env,~control.value(11).linexp(0,1,3000,20000));
		sig = ~linedelay.value(~control.value(9),sig)*~control.value(8);
		Out.ar(~mixer,Pan2.ar(a*sig));
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
		Out.ar(~mixer,Pan2.ar(sig));

	}).send;

	SynthDef(\repeat,{
		arg control;
		var cntrl = {|n| Lag.kr(In.kr((control + n)),0.1)};

		var dur = cntrl.value(2)*BufDur.kr(~record);
		var nstart = cntrl.value(0)* BufDur.kr(~record);
		var where = cntrl.value(1)*BufSamples.kr(~record);
		var rate,env2,sig,env,noise,envnoise,sines,envsines,tri,envtri,start;
		start = DelayL.kr(In.kr(~reset),BufDur.kr(~record),nstart);

		rate = ((cntrl.value(4)*16) + 1) * ~linedur/2;
		sines = Phasor.kr(start,1/rate/ControlRate.ir,-0.5,0.5);

		env2 = EnvGen.ar(Env.perc(0.01,rate,curve:0),sines);

		//var stop = Stepper.kr(In.kr(~ping),In.kr(~reset),0,7,1,nstop + nstart);
		env = EnvGen.ar(Env.perc(0.001*dur,dur,curve:0),start);
		sig = PlayBuf.ar(2,~record,cntrl.value(5)*2,sines,where,1)*env*env2;
		Out.ar(~repeatout,sig*cntrl.value(3));
	}).send;



	// load the file or set all param to 0 for all parameter sets
	~mo = MIDIOut(0).connect(1); //feedback for channel 1
	~mo.latency = 0;

	~setversion = {|n|
		~version = n;
		File.exists(~name.value() ++ ".data").if(
			{~controls[0].setnSynchronous(Object.readArchive(~name.value() ++ ".data"))},
			{~controls[0].setnSynchronous(Array.fill(~ncontrols,{0}))});
		~controls[0].getnSynchronous(~ncontrols).do({|v,c| ~mo.control(1,c,v*128)});
	};
	~copyversion = {|n|
		~version = n;
	};

	~setversion.value(1);

	2.wait;
    ~writecond=true;
	// parameter archiving
	(
		fork {
			inf.do {
				~writecond.if(
					{
					~writecond = false;
					~controls[0].getnSynchronous(~ncontrols).writeArchive(~name.value() ++ ".data");
					Synth.tail(nil,\recorder);
					Synth.tail(nil,\repeatrecorder);

					(32*~linedur).wait;
					~recordmixed.write(~name.value() ++ ".wav" ,"WAV");
					(~name.value() ++ " written").postln
					}
					,
					{1.wait}
				)
			}

		}
	)


});

)



(
~pinger.free;
~pinger = {Out.kr(~ping,Impulse.kr(1/~linedur))}.play;
~resetter.free;
~resetter= {DelayL.kr(Out.kr(~reset,PulseDivider.kr(In.kr(~ping),16)),0.1,0.05)}.play;



~kick.free;
~kick = Synth(\kick);
~h1.free;
~h1 = Synth(\zz,[\w,1,\a,1]);
~h2.free;
~h2 = Synth(\zz,[\w,0,\a,0.03]);
~sn.free;
~sn = Synth(\snare);


~g.free;
~g = Synth(\repeat,[\control,~controls[24].index]);

~i.free;
~i = Synth(\repeat,[\control,~controls[32].index]);


~h.free;
~h = Synth(\repeat,[\control,~controls[40].index]);
~l.free;
~l = Synth(\repeat,[\control,~controls[48].index]);


~mainout.free;
~mainout = {Out.ar(0,In.ar(~mixer,2))}.play(addAction:\addToTail);
~repeatoutout.free;
~repeatoutout = {Out.ar(0,In.ar(~repeatout,2))}.play(addAction:\addToTail);


)


~repeatrecord.plot()


~mixer.scope()

	~record.plot()
	~recordmixed.plot()



~setversion.value(2);
~version=5;
