package zui;

import zui.Zui;
import kha.Color;

@:access(zui.Zui)
class MyExt {
    public static function timeline(ui: Zui, from: Float, to: Float, divisions: Int, partitions: Array<TlineSeg>) {
		if (!ui.isVisible(ui.ELEMENT_H())) { ui.endElement(); }
		// if (ui.getReleased()) {
		// 	if (++handle.position >= texts.length) handle.position = 0;
		// 	handle.changed = ui.changed = true;
		// }
        // else handle.changed = false;

		var hover = ui.getHover();
        drawTimeline(ui, hover, from, to, divisions, partitions); // Bunch of Rectangles
        
		ui.endElement();
	}

	static function drawTimeline(ui: Zui, hover: Bool, from: Float, to: Float, divisions: Int, partitions: Array<TlineSeg>) {
		// events
        var x = ui._x + ui.buttonOffsetY;
		var y = ui._y + ui.buttonOffsetY;
		var w = ui._w - ui.buttonOffsetY * 2;

        ui.g.color = hover ? ui.t.ACCENT_HOVER_COL : ui.t.ACCENT_COL;
		if (!hover) if (!ui.enabled) ui.fadeColor();
        ui.g.drawRect(x, y, w, ui.BUTTON_H());

        if (!ui.enabled) ui.fadeColor();
        var base_color_int = hover ? ui.t.ACCENT_HOVER_COL : ui.t.ACCENT_COL;
        var color = kha.Color.fromValue(base_color_int);

        var iter_length = partitions.length;
        for (i in 0...iter_length){
            var line = partitions[i];
            var offset = (line.from - from) / (to - from);
            var sliderX = w * offset;

            offset = (line.to - line.from) / (to - from);
            var sliderW = w * offset;
            sliderW = Math.max(Math.min(sliderW, w), 0);

            // color = changeColor(color, divisions, partitions.length, Std.int(to * 10));
            ui.g.color = line.color;
            ui.g.fillRect(sliderX, y, sliderW, ui.BUTTON_H());
        }

        // time scale
        var marking : String;
        var xOffset : Float = ui.buttonOffsetY;
        var yOffset : Float = 0;
        var xSep : Float = 0;
        var num_markings : Int = divisions + 1;
        var markings_length_sum : Float = 0;
        ui.g.font = ui.ops.font;
		ui.g.fontSize = ui.fontSize;
        
        var texts = [for (marking in 0...num_markings) Std.string( from + (to - from) / divisions * marking) ];

        for (marking in texts){
		    markings_length_sum += ui.ops.font.width(ui.fontSize, marking);
        }

        while (markings_length_sum > w){
            markings_length_sum -= ui.ops.font.width(ui.fontSize, texts.pop());
            num_markings--;
        }

        xSep = (w - markings_length_sum) / (num_markings - 1);

		ui.g.color = ui.t.TEXT_COL;
		if (!ui.enabled) ui.fadeColor();
        ui.g.pipeline = ui.rtTextPipeline;
        for (marking in texts){
            ui.g.drawString(marking, ui._x + xOffset, ui._y + ui.fontOffsetY + yOffset);
            xOffset = xOffset + xSep + ui.ops.font.width(ui.fontSize, marking);
        }
        ui.g.pipeline = null;
    }
    
    static function changeColor(color: Color, a: Int, b: Int, c: Int) : Color {
        var r = (color.Rb + 53 * a) % 200;
        var g = (color.Gb + 71 * b) % 200;
        var b = (color.Bb + 59 * c) % 200;
        return kha.Color.fromBytes(r, g, b, color.Ab);
    }

    public static function limitedIntInput(ui: Zui, handle: Handle, label = "", limit:Int, align: Align = Left): Float {
		handle.text = Std.string(handle.value);
        var text = ui.textInput(handle, label, align);
        var parsed = Std.parseInt(text.substr(0, limit));
		handle.value = parsed != null ? parsed : 0;
		return handle.value;
	}
}

typedef TlineSeg = {
    var from : Float;
    var to : Float;
    var color : Color;
}