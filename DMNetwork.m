//
//  DHNetwork.m
//
//
//  Created by David Murray on 2013-03-02.
//
//

#import "DMNetwork.h"

@implementation DMNetwork
@synthesize SSID             = _SSID;
@synthesize RSSI             = _RSSI;
@synthesize encryptionModel  = _encryptionModel;
@synthesize BSSID            = _BSSID;
@synthesize channel          = _channel;
@synthesize isAppleHotspot   = _isAppleHotspot;
@synthesize isCurrentNetwork = _isCurrentNetwork;

- (id)initWithNetwork:(WiFiNetworkRef)network
{
    self = [super init];

    if (self) {
        _network = (WiFiNetworkRef)CFRetain(network);
    }

    return self;
}

- (void)dealloc
{
    [_SSID release];
    [_encryptionModel release];
    [_BSSID release];
    CFRelease(_network);

    [super dealloc];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"SSID: %@ RSSI: %f Encryption Model: %@ Channel: %i AppleHotspot: %i CurrentNetwork: %i", [self SSID], [self RSSI], [self encryptionModel], [self channel], [self isAppleHotspot], [self isCurrentNetwork]];
}


- (void)populateData
{
    // SSID

    NSString *SSID = (NSString *)WiFiNetworkGetSSID(_network);
    [self setSSID:SSID];

    // RSSI

    CFNumberRef RSSI = (CFNumberRef)WiFiNetworkGetProperty(_network, kWiFiScaledRSSIKey);

    float strength;
    CFNumberGetValue(RSSI, kCFNumberFloatType, &strength);

    strength = strength * 100;

    // Round to the nearest integer.
    strength = ceilf(strength);

    // Convert to a negative number.
    strength = strength * -1;

    [self setRSSI:strength];

    // Encryption model

    if (WiFiNetworkIsWEP(_network))
        [self setEncryptionModel:@"WEP"];
    else if (WiFiNetworkIsWPA(_network))
        [self setEncryptionModel:@"WPA"];
    else
        [self setEncryptionModel:@"None"];

    // Channel

    CFNumberRef networkChannel = (CFNumberRef)WiFiNetworkGetProperty(_network, CFSTR("CHANNEL"));

    int channel;
    CFNumberGetValue(networkChannel, kCFNumberIntType, &channel);

    [self setChannel:channel];

    // Apple Hotspot

    BOOL isAppleHotspot = WiFiNetworkIsApplePersonalHotspot(_network);
    [self setIsAppleHotspot:isAppleHotspot];

    // BSSID

    NSString *BSSID = (NSString *)WiFiNetworkGetProperty(_network, CFSTR("BSSID"));
    [self setBSSID:BSSID];
}

@end
