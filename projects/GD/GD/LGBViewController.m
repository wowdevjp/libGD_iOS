
#import "LGBViewController.h"
#include "gd.h"

static double remap(double value, double inputMin, double inputMax, double outputMin, double outputMax)
{
    return (value - inputMin) * ((outputMax - outputMin) / (inputMax - inputMin)) + outputMin;
}

@implementation LGBViewController
{
    IBOutlet UIWebView *_webView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *tmpPath = [tmpDir stringByAppendingPathComponent:@"tmp.gif"];
    
    FILE *fp = fopen(tmpPath.UTF8String, "wb");
    
    int width = 300;
    int height = 300;
    int frameRate = 10;
    int delay = (int)round((1.0 / (double)frameRate) * 100.0);
    gdImagePtr image = gdImageCreate(width, height);
    gdImageGifAnimBegin(image, fp, FALSE, 0);
    
    int frameCount = frameRate * 6;
    for(int i = 0 ; i < frameCount ; ++i)
    {
        gdImagePtr frameImage = gdImageCreateTrueColor(width, height);
        double elapsed = (1.0 / (double)frameRate) * i;
        for(int y = 0 ; y < height ; ++y)
        {
            double offsety = remap(y, 0, height - 1, 0, 10);
            
            for(int x = 0 ; x < width ; ++x)
            {
                double offsetx = remap(x, 0, width - 1, 0, 10);
                
                uint8_t r = ABS(sin(offsetx + elapsed)) > 0.7 ? 255 : 0;
                uint8_t g = ABS(cos(offsetx + elapsed)) > 0.7 ? 255 : 0;
                uint8_t b = ABS(sin(offsety + elapsed)) > 0.7 ? 255 : 0;
                gdImageSetPixel(frameImage, x, y, gdTrueColor(r, g, b));
            }
        }
        gdImageTrueColorToPalette(frameImage, TRUE, gdMaxColors);
        gdImageGifAnimAdd(frameImage, fp, TRUE, 0, 0, delay, gdDisposalNone, NULL);
        gdImageDestroy(frameImage);
    }
    gdImageGifAnimEnd(fp);
    fclose(fp);
    gdImageDestroy(image);
    
    NSData *gif = [NSData dataWithContentsOfFile:tmpPath];
    [_webView loadData:gif MIMEType:@"image/gif" textEncodingName:@"UTF-8" baseURL:nil];
}

@end
