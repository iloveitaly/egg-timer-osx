//
//  MABEtchedTextField.m
//  EggTimer
//
//  Created by Michael Bianco on 10/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MABEtchedTextField.h"


@implementation MABEtchedTextField

- (id) initWithFrame:(NSRect)frameRect {
	if(self = [super initWithFrame:frameRect]) {
		[self setDrawsBackground:NO];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)coder {
	if(self = [super initWithCoder:coder]) {
		[self setDrawsBackground:NO];
	}
	
	return self;
}

- (void) drawRect:(NSRect)rect {
	NSShadow *textShadow = [NSShadow new];
	[textShadow setShadowOffset:NSMakeSize(2.0, -2.0)];
	[textShadow setShadowBlurRadius:0.0];
	[textShadow set];
	[super drawRect:rect];
	[textShadow release];
}

@end
