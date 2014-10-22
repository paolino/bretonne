(
// streams as a sequence of pitches
    var stream, dur;
    dur = 1/8;
    stream = Routine.new({
        loop({
            if (0.coin, {
                // run of fifths:
                24.yield;
                31.yield;
                36.yield;
                43.yield;
                48.yield;
                55.yield;
            });
            rrand(2,5).do({
                // varying arpeggio
                60.yield;
                [63].choose.yield;
                65.yield;
                #[72].choose.yield;
            });
            // random high melody
            //rrand(3,9).do({ #[74,75,77,79,81].choose.yield });
        });
    });
    Routine({
        loop({
		Synth(\help_SPE1, [ \freq, (stream.next - 24).midicps ] );
            dur.wait; // synonym for yield, used by .play to schedule next occurence
        })
    }).play
)
(
var a, b;
a = Pseries.new(10, 3, 8);    // stream starts at 10, steps by 3 and has length 8
b = a.asStream;
9.do({ b.next.postln; });    // print 9 values from stream
)


(
    s = Server.local;
    SynthDef(\help_SPE1, { arg i_out=0, freq;
        var out;
        out = RLPF.ar(
            LFSaw.ar( freq, mul: EnvGen.kr( Env.perc, levelScale: 0.3, doneAction: 2 )),
		(80 + (10 * SinOsc.kr(8/8))).midicps,
            0.3
        );
        // out = [out, DelayN.ar(out, 0.04, 0.04) ];
        10.do({ out = AllpassN.ar(out, 0.05, [0.01.rand, 0.05.rand], 4) });
        Out.ar( i_out, out );
    }).send(s);
)
{ var freq = 1000; [LFNoise1.ar(freq), Impulse.ar(freq)] }.plot
120.midicps