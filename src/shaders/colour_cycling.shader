shader_type canvas_item;

uniform float cascade_speed=0.3;
uniform vec4 cascade_color : hint_color;
void fragment() {
     
vec4 c = textureLod(TEXTURE, UV, 0.0);
vec3 rgb = mod(c.rgb - TIME * cascade_speed, 0.5) * cascade_color.rgb;
COLOR = vec4(rgb,c.a);
}

uniform sampler2D palette;
uniform int palettesize = 256;
uniform float speed = 10.0;
uniform int index1a = 0;
uniform int index1b = 10;

int getpaletteidx(vec3 color)
{
    for(int x=index1a;x<index1b;x++)
    {
        ivec2 coord = ivec2(x,0);
        vec3 pixelcolor = texelFetch(palette, coord, 0).rgb;    
        if(distance(color,pixelcolor) == 0.0 )
        {
            return x;
        }
    }
    return -1;
}

vec3 getpalettecolor(int x)
{
    ivec2 coord = ivec2(x,0);
    return texelFetch(palette, coord, 0).rgb;
}


void fragment() {
     
    vec4 incolor = texture(TEXTURE, UV);
     
    int idx = getpaletteidx(incolor.rgb);
     
    float fdelta = float(idx) - TIME * speed;
    float mod2 = mod(fdelta,float(palettesize));
    int delta = int(mod2);
     
    vec3 color = getpalettecolor(delta);
     
    if(idx > -1)
    {
        vec3 swappedcolor = getpalettecolor(idx);
        COLOR.rgb = color.rgb;  
    }
    else   
    {
        COLOR.rgb = vec3(0,0,0);
    }
    COLOR.a = incolor.a;
}