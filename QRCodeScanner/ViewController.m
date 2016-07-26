//
//  ViewController.m
//  QRCodeScanner
//
//  Created by jayaprada on 26/07/16.
//  Copyright © 2016 jayaprada. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>{

    BOOL isFirst;
}
//Scanner

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
- (IBAction)startScanning:(id)sender;
@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,strong) AVCaptureDevice *device;

@property(nonatomic,strong) AVCaptureDeviceInput *input;

@property(nonatomic,strong)  AVCaptureMetadataOutput *output;
@property(nonatomic,strong)  AVCaptureVideoPreviewLayer *prevLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.resultImageView.layer.borderWidth = 5.f;
    
    self.scanBtn.layer.borderColor = [UIColor redColor].CGColor;
    self.scanBtn.layer.borderWidth = 2.5f;
    // Do any additional setup after loading the view, typically from a nib.
}
-(IBAction)startScanning:(id)sender{
    isFirst=true;            _label.text = @"";

    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.resultImageView.frame;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
}




- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
        {
            if (isFirst) {
                isFirst=false;
                _label.text =[NSString stringWithFormat:@"Result is :%@",detectionString];
                [_session stopRunning];
                _session = nil;
                [_prevLayer removeFromSuperlayer];
                break;
            }
        }
        else
            _label.text = @"(none)";
    }
    
    //    _highlightView.frame = highlightViewRect;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
