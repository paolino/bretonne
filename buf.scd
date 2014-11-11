s.boot;
FreqScope();
FreqScopeView();



f = {|n| Lag.kr(In.kr(m[n]),0.1)}


Buffer.read(s,"/usr/local/share/renoise-3.0.0/Library/Samples/HiHats/Closed/dh_clhat_loose_groovy.flac",0,-1,nil,2); // remember to
Buffer.read(s,"/usr/local/share/renoise-3.0.0/Library/Samples/HiHats/Closed/dh_clhat_loose_acid.flac",0,-1,nil,2); // remember to
 // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to
Buffer.read(s,,0,-1,nil,2); // remember to


d = Bus.control();

(
var lps = 125/15;
var f = {|n| Lag.kr(In.kr(m[n]),0.1)}; // fluid control
var e = Bus.control();

// main line beat
{Out.kr(d,Impulse.kr(lps))}.play;
//
{Out.kr(e,1 - Mix.ar
	(SinOsc.kr
		(lps/16*[2,3,4,5,6,7,8]
			,f.value([0,1,2,3,4,5])*2*pi
			,f.value([6,7,8,9,10,11]))
	).abs
	)}.play;
)

(
var bufnum = Buffer.read(s,"/home/paolino/k1.wav",0,-1,nil,2);
var out= 0;

SynthDef(\help_PlayBuf, {
    var start = In.kr(e) * BufFrames.kr(bufnum)/(1 + 4 * f.value(14));
	var sig =   PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), In.kr(d), start , 0);
	var env = EnvGen.ar(Env.linen(0.01,0.9*15/125-0.03,0.01),In.kr(d));
	Out.ar(out,f.value(12) *  env  * sig );

}).play;
)

Synth(\help_PlayBuf);

(
// note, asWavetable is false b/c BufRd doesn’t use wavetable format
~sinlfobuf = Buffer.alloc(s, 1024, 1, completionMessage: { |buf|
   buf.sine1Msg(#[1], asWavetable: false);
});
~rsinosc = {|t_reset = 0, lfobuf, lfofreq = 1, lfoamp = 0.1, phase = 0 |
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


"/home/paolino/k1.wav"

