w = Window.new

w.front


s.boot;

b = ~record;
~record
p = Plotter.new("main",Rect(0, 0, 200,50),w)

a = ~record.loadToFloatArray(0,1000, {|a| p.value=a});

p.refresh
p.value=a;


b.plot(minval: nil, maxval: nil); // auto range

b.plot(minval: 0, maxval: nil); // semi-auto range


(
var a1,a2,a3,a4,a5,c1,c2,c3,c4,c5;
w = Window.new;
w.layout = VLayout();
a1= Plotter(parent:w);
a2 = Plotter(parent:w);
a3 = Plotter(parent:w);
a4 = Plotter(parent:w);
a5 = Plotter(parent:w);

w.front;
c1=true;
c2=true;
c3=true;
c4=true;
c5=true;

r=fork {
	inf.do {
		(c1 && c2 && c3 && c4 && c5).if({
		c1=c2=c3=c4=c5=false;
		~record.loadToFloatArray(0,48000, {|v| {a1.value=v;c1=true}.defer;});
			~repeatrecord[0].loadToFloatArray(0,48000, {|v| {a2.value=v;c2=true}.defer;});
			~repeatrecord[1].loadToFloatArray(0,48000, {|v| {a3.value=v;c3=true}.defer;});
			~repeatrecord[2].loadToFloatArray(0,48000, {|v| {a4.value=v;c4=true}.defer;});
			~repeatrecord[3].loadToFloatArray(0,48000, {|v| {a5.value=v;c5=true}.defer;});

		},{0.01.wait})

	};
};
)
~record
r.stop;
(
w = Window("GUI Introduction").background_(Color.rand).front;
b = Button(w, Rect(10,10,100,30)).states_([
    ["One",Color.rand,Color.rand],
    ["Two",Color.rand,Color.rand],
    ["Three",Color.rand,Color.rand]
]);
l = ListView.new(w, Rect(10,50,200,100))
    .items_(["One","Two","Three"])
    .colors_([Color.rand,Color.rand,Color.rand])
    .hiliteColor_(Color.blue)
    .selectedStringColor_(Color.white);
s = Slider(w, Rect(10, 160, 200, 20))
    .knobColor_(Color.rand)
    .background_(Color.rand);
)
(
w = Window.new;
w.layout = VLayout(
    TextView().string_("Foo\nBar\nFoo\nBar\nFoo"),
    HLayout(
        Button().states_([["Foo"]]),
        [TextField().string_("Bar"), stretch:1],
        [TextField().string_("BarBarBar"), stretch:4]
    )
);
w.front;
)