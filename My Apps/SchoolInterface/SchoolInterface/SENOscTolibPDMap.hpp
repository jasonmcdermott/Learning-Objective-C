//
//  oscTolibPDMap.h
//  ofxParticle
//
//  Created by Andrew Nicholson on 25/04/13.
//
//

#ifndef __ofxParticle__oscTolibPDMap__
#define __ofxParticle__oscTolibPDMap__

//#include <iostream>

namespace wrapper {
    


class SENOscTolibPDMap {
    
public:
    SENOscTolibPDMap();
    ~SENOscTolibPDMap();
    
    void startSession();
    void endSession();
    void decodeMessage(const char *msg, float value);
    void rawPulse();
    void sendtoPDBaseReliability(int signal);
};

}

#endif /* defined(__ofxParticle__oscTolibPDMap__) */
