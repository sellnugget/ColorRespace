uniform sampler2D texture;
uniform ivec3 channelRange;
uniform bool Use_HSL;
uniform int DrawColorSpace;

const float EPSILON = 1e-10;

vec3 HUEtoRGB(float hue)
{
    // Hue [0..1] to RGB [0..1]
    // See http://www.chilliant.com/rgb2hsv.html
    vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
    return clamp(rgb, 0., 1.);
}

vec3 RGBtoHCV(in vec3 rgb)
{
    // RGB [0..1] to Hue-Chroma-Value [0..1]
    // Based on work by Sam Hocevar and Emil Persson
    vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
    vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
    float c = q.x - min(q.w, q.y);
    float h = abs((q.w - q.y) / (6. * c + EPSILON) + q.z);
    return vec3(h, c, q.x);
}

vec3 HSVtoRGB(in vec3 hsv)
{
    // Hue-Saturation-Value [0..1] to RGB [0..1]
    vec3 rgb = HUEtoRGB(hsv.x);
    return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}

vec3 HSLtoRGB(in vec3 hsl)
{
    // Hue-Saturation-Lightness [0..1] to RGB [0..1]
    vec3 rgb = HUEtoRGB(hsl.x);
    float c = (1. - abs(2. * hsl.z - 1.)) * hsl.y;
    return (rgb - 0.5) * c + hsl.z;
}

vec3 RGBtoHSV(in vec3 rgb)
{
    // RGB [0..1] to Hue-Saturation-Value [0..1]
    vec3 hcv = RGBtoHCV(rgb);
    float s = hcv.y / (hcv.z + EPSILON);
    return vec3(hcv.x, s, hcv.z);
}

vec3 RGBtoHSL(in vec3 rgb)
{
    // RGB [0..1] to Hue-Saturation-Lightness [0..1]
    vec3 hcv = RGBtoHCV(rgb);
    float z = hcv.z - hcv.y * 0.5;
    float s = hcv.y / (1. - abs(z * 2. - 1.) + EPSILON);
    return vec3(hcv.x, s, z);
}



void main()
{
    // lookup the pixel in the texture
    vec4 pixel = texture2D(texture, gl_TexCoord[0].xy);




    if(!Use_HSL)
    {
        int R =	round(pixel.r * pow(2, channelRange.r));
        int G = round(pixel.g * pow(2, channelRange.g));
        int B = round(pixel.b * pow(2, channelRange.b));
	
        pixel = vec4(R/pow(2, channelRange.r), G/pow(2, channelRange.g), B/pow(2, channelRange.b), 1.0);


       

        if(DrawColorSpace == 1){
            float SpaceQualityx = round(gl_TexCoord[0].y * pow(2, channelRange.r))/pow(2, channelRange.r);
            float SpaceQualityy = round(gl_TexCoord[0].x * pow(2, channelRange.b))/pow(2, channelRange.b);
            pixel = vec4(vec3(SpaceQualityx, SpaceQualityy, 0.5),1.0);
        }
        if(DrawColorSpace == 2){
            float SpaceQuality = round(gl_TexCoord[0].y * pow(2, channelRange.g))/pow(2, channelRange.g);
            pixel = vec4(0.0, SpaceQuality, 0.0,1.0);
        }

    }
    else {

		
        vec3 hsl = RGBtoHSL(pixel.rgb);
        int R = round(hsl.r * pow(2, channelRange.r));
        int G = round(hsl.g * pow(2, channelRange.g));
        int B = round(hsl.b * pow(2, channelRange.b));



        pixel = vec4(HSLtoRGB(vec3(R/pow(2, channelRange.r), G/pow(2, channelRange.g), B/pow(2, channelRange.b))), 1.0);

       

        if(DrawColorSpace == 1){
            float SpaceQualityx = round(gl_TexCoord[0].x * pow(2, channelRange.r))/pow(2, channelRange.r);
            float SpaceQualityy = round(gl_TexCoord[0].y * pow(2, channelRange.b))/pow(2, channelRange.b);
            pixel = vec4(HSLtoRGB(vec3(SpaceQualityx, 1 - SpaceQualityy, 0.5)),1.0);
        }
        if(DrawColorSpace == 2){
            float SpaceQuality = round(gl_TexCoord[0].y * pow(2, channelRange.g))/pow(2, channelRange.g);
            pixel = vec4(HSLtoRGB(vec3(1, SpaceQuality, 0.5)),1.0);
        }
    }
    

    // multiply it by the color
    gl_FragColor = gl_Color * pixel;
}