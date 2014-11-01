s.boot;
FreqScope();
FreqScopeView();

// map controller
(
m = {Bus.control()}!24;
c =  Array.fill(8,{arg i;CCResponder({|s,ch,c,v| m[i].set(v/128)},nil,1,i+21)}) ++
Array.fill(16,{arg i;CCResponder({|s,ch,c,v| m[i+8].set(v/128)},nil,1,i+41)})

)
NoteOnResponder({|s,ch,c,v| m},nil,1,nil);
// map notes
s.boot // Boot the server, if you need to

// read a whole sound into memory
// note: not *that* columbia, the first one
b = Buffer.read(s, "/home/paolino/music/WAV/ByType/Kick/Fl_Pdkmh_Antepaste_Kick1.wav",0,-1,nil,2); // remember to free the
Buffer.read(s,"/home/paolino/music/WAV/ByType/Kick/Fl_Pdkmh_Derelict_Kick1.wav" ,0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/WAV/ByType/HiHat/TF01_Eckle_Hihat6.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/WAV/ByType/HiHat/TF01_Acaer_Hihat2.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/WAV/ByType/HiHat/TF01_Acaer_Hihat3.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/WAV/ByType/Percussion/TF01_Chillaid_Percussion2.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/Kurzweil Kit 01/CYCdh_Kurz01-Kick03.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/- 4- Viento 'e terra slice 0A.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/10-05-2014-00:19.wav",0,-1,nil,2); // remember to
Buffer.read(s,"/home/paolino/music/Untitled (122 BPM)_Track 05.wav",0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to


f = {|n| Lag.kr(In.kr(m[n]),0.1)}
(
// trigger one shot on each pulse
SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0, effe|
	var trig= Impulse.kr(f.value(15)*16);
	var bar = Stepper.kr(trig,0,0,15,1,-1).poll;
	var cyc = f.value(5) + ~rsin.value(bar,~sinlfobuf, 16*f.value(3),f.value(4), f.value(6));
	var cyc2 = 1 + f.value(13) + ~rsin.value(bar,~sinlfobuf, 16*f.value(11),f.value(12), f.value(14));
	var env=EnvGen.ar(Env.perc(0.001),trig);
	var shcyc2 = Latch.kr(cyc2,trig);
	var shcyc = Latch.kr(cyc,trig);
	var ctrig = (cyc < 0.3) * trig;
	var sig = env*f.value(0)* PlayBuf.ar(2, bufnum, shcyc2*BufRateScale.kr(bufnum), ctrig, shcyc * BufFrames.kr(bufnum), 0);
	sig = RHPF.ar(sig,20 + (f.value(1)*200));
	sig = RLPF.ar(sig,1000 + (f.value(9)*10000));

	Out.ar(out,sig);

}).play(s, [\out, 0, \bufnum, b]);
)


(
// note, asWavetable is false b/c BufRd doesn’t use wavetable format
~sinlfobuf = Buffer.alloc(s, 1024, 1, completionMessage: { |buf|
   buf.sine1Msg(#[1], asWavetable: false);
});
~rsin = {|t_reset = 0, lfobuf, lfofreq = 1, lfoamp = 0.1, phase |
	  var   lfosize = BufFrames.kr(lfobuf),
      ph = Phasor.kr(t_reset, lfofreq / ControlRate.ir, 0.0, 1.0);
	BufRd.kr(1, lfobuf, lfosize * (ph + phase), interpolation: 1)*lfoamp;
}
)
SynthDef(\lfobuf, { |t_reset = 0, lfobuf, lfofreq = 1, lfoamp = 0.1|
   var   lfosize = BufFrames.kr(lfobuf),
      ph = Phasor.kr(t_reset, lfofreq / ControlRate.ir, 0.0, 1.0),
      lfo = BufRd.kr(1, lfobuf, lfosize * ph, interpolation: 1);
	Out.ar(0,SinOsc.ar(440 * ((lfo * lfoamp) + 1))!2*0.1)
}).send(s);
)

a = Synth(\lfobuf, [lfobuf: ~sinlfobuf]);

a.set(\t_rese,t, 1);

a.free;




