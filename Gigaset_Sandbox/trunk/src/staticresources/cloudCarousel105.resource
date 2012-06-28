//////////////////////////////////////////////////////////////////////////////////
// CloudCarousel V1.0.5
// (c) 2011 by R Cecco. <http://www.professorcloud.com>
// MIT License
//
// Reflection code based on plugin by Christophe Beyls <http://www.digitalia.be>
//
// Please retain this copyright header in all versions of the software
//////////////////////////////////////////////////////////////////////////////////

(function($) {

	// START Reflection object.
	// Creates a reflection for underneath an image.
	// IE uses an image with IE specific filter properties, other browsers use the Canvas tag.	
	// The position and size of the reflection gets updated by updateAll() in Controller.
	function Reflection(img, reflHeight, opacity, salesforceURL) {				
		
		var reflection, imageWidth = img.width, imageHeight = img.width, gradient, parent;
		parent = $(img);
		var reflection = parent.clone();
		reflection.css({"-webkit-transform":"scale(1, -1)", "-moz-transform":"scale(1, -1)", "-ms-transform":"scale(1, -1)", "transform":"scale(1, -1)"});

		reflection.find("span").each( function() {
			$(this).addClass("textreflectionClone");		
		});

		var div = document.createElement('div');
		$(div).addClass("reflection-container");
		$(div).append(reflection);
		if(parent.find('.showTick').text().indexOf('true') != -1)
			parent.append('<div class="cloudcarousel-check"><img src="'+salesforceURL+'/images/check.png"" alt="" origWidth="31" origHeight="31"/></div>');
		parent.append(div);
	}	//END Reflection object

	// START Item object.
	// A wrapper object for items within the carousel.
	var	Item = function(imgIn, options)
	{			
		this.orgWidth = 245;//imgIn.width;			
		this.orgHeight = 151;//imgIn.height;		
		this.image = imgIn;
		this.reflection = null;					
		this.alt = imgIn.alt;
		this.title = imgIn.title;
		this.imageOK = false;		
		this.options = options;				
						
		this.imageOK = true;	
		
		if (this.options.reflHeight > 0)
		{													
			this.reflection = new Reflection(this.image, this.options.reflHeight, this.options.reflOpacity, this.options.salesforceURL);					
		}
		$(this.image).css('position','absolute');	// Bizarre. This seems to reset image width to 0 on webkit!					
	};// END Item object
	
	
	// Controller object.
	// This handles moving all the items, dealing with mouse clicks etc.	
	var Controller = function(container, images, options)
	{						
		var	items = [], funcSin = Math.sin, funcCos = Math.cos, ctx=this;
		this.controlTimer = 0;
		this.stopped = false;
		//this.imagesLoaded = 0;
		this.container = container;
		this.xRadius = options.xRadius;
		this.yRadius = options.yRadius;
		this.showFrontTextTimer = 0;
		this.autoRotateTimer = 0;
		if (options.xRadius === 0)
		{
			this.xRadius = ($(container).width()/2.3);
		}
		if (options.yRadius === 0)
		{
			this.yRadius = ($(container).height()/6);
		}

		this.xCentre = options.xPos;
		this.yCentre = options.yPos;
		this.frontIndex = 0;	// Index of the item at the front
		
		// Start with the first item at the front.
		this.rotation = this.destRotation = Math.PI/2;
		this.timeDelay = 1000/options.FPS;
								
		// Turn on the infoBox
		if(options.altBox !== null)
		{
			$(options.altBox).css('display','block');	
			$(options.titleBox).css('display','block');	
		}
		// Turn on relative position for container to allow absolutely positioned elements
		// within it to work.
		$(container).css({ position:'relative', overflow:'hidden'} );
	
		$(options.buttonLeft).css('display','inline');
		$(options.buttonRight).css('display','inline');
		
		// Setup the buttons.
		$(options.buttonLeft).bind('mouseup',this,function(event){
			event.data.rotate(-1);	
			return false;
		});
		$(options.buttonRight).bind('mouseup',this,function(event){															
			event.data.rotate(1);	
			return false;
		});
		$(options.autoStart).bind('mouseup',this,function(event){ 
			var context = event.data;
		    clearTimeout(context.showFrontTextTimer);
			if ( options.autoRotate == 'no' ){
				options.autoRotate = "no";
				//context.showFrontTextTimer = setTimeout( function(){context.showFrontText();},1000);
                //context.autoRotate(); 
			}else{
				options.autoRotate = "no";
				clearTimeout(options.autoRotateTimer);
			}
		    
                    return false;
            });	
		container.onselectstart = function () { return false; };		// For IE.

		this.innerWrapper = $(container).wrapInner('<div style="position:absolute;width:100%;height:100%;left: 30px;"><a href="#" onClick="return changePropertySecondPage();" /></div>').children()[0];
		
		// Shows the text from the front most item.
		this.showFrontText = function()
		{	
			var curindex = this.frontIndex;
			if(curindex<0){curindex *= -1;}
			if ( items[curindex] === undefined ) { return; }	// Images might not have loaded yet.
			$(options.titleBox).html( $(items[curindex].image).attr('title'));
			$(options.altBox).html( $(items[curindex].image).attr('alt'));	
		};
						
		this.go = function()
		{				
			if(this.controlTimer !== 0) { return; }
			var	context = this;
			this.controlTimer = setTimeout( function(){context.updateAll();},this.timeDelay);					
		};
		
		this.stop = function()
		{
			clearTimeout(this.controlTimer);
			this.controlTimer = 0;				
		};
		
		
		// Starts the rotation of the carousel. Direction is the number (+-) of carousel items to rotate by.
		this.rotate = function(direction)
		{	
			this.frontIndex -= direction;
			this.frontIndex %= items.length;					 			
			this.destRotation += ( Math.PI / items.length ) * ( 2*direction );
			this.showFrontText();
			this.go();			
		};
		
		
		this.autoRotate = function()
		{			
			if ( options.autoRotate !== 'no' )
			{
				var	dir = (options.autoRotate === 'right')? 1 : -1;
				options.autoRotateTimer = setInterval( function(){ctx.rotate(dir); }, options.autoRotateDelay );
			}
		};
		
		// This is the main loop function that moves everything.
		this.updateAll = function()
		{			
			var	minScale = options.minScale;	// This is the smallest scale applied to the furthest item.
			var smallRange = (1-minScale) * 0.5;
			var	w,h,x,y,scale,item,sinVal;
			
			//current index
			var currIndex= (this.frontIndex>=0)?this.frontIndex:(images.length + this.frontIndex);
			
			var	change = (this.destRotation - this.rotation);				
			var	absChange = Math.abs(change);
	
			this.rotation += change * options.speed;
			if ( absChange < 0.001 ) { this.rotation = this.destRotation; }			
			var	itemsLen = items.length;
			var	spacing = (Math.PI / itemsLen) * 2; 
			//var	wrapStyle = null;
			var	radians = this.rotation;
			var	isMSIE = $.browser.msie;
		
			// Turn off display. This can reduce repaints/reflows when making style and position changes in the loop.
			// See http://dev.opera.com/articles/view/efficient-javascript/?page=3			
			this.innerWrapper.style.display = 'none';		
			
			var	style;
			var	px = 'px', reflHeight;	
			var context = this;
			var opas = 1;

			for (var i = 0; i<itemsLen ;i++)			
			{
			   $('#bullet' + i).attr("src", options.salesforceURL+"/images/bullet.png");
			}

			for (var i = 0; i<itemsLen ;i++)
			{	
				item = items[i];
				sinVal = funcSin(radians);
				
				scale = ((sinVal+1) * smallRange) + minScale;

				x = this.xCentre + (( (funcCos(radians) * this.xRadius) - (item.orgWidth*0.5)) * scale);
				y = this.yCentre + (( (sinVal * this.yRadius)  ) * scale);		

				if (item.imageOK)
				{
					var	img = item.image;
					w = item.orgWidth * scale;					
					h = item.orgHeight * scale;

			       if(currIndex == i){
			    	   scale = 1;
						opas = 1;
					   $('#bullet' + i).attr("src", options.salesforceURL+"/images/bullet_cr.png");
					}else{
						opas = 0.55;
					}
					
					$(img).css({"left":x + px,"top":(y + scale*10) + px,"z-index":((scale * 100)>>0),"position":"absolute","width":(w + px),"height":(h + px),"opacity":opas,"-webkit-transform":"scale(" + scale + ")", "-moz-transform":"scale(" + scale + ")","-o-transform":"scale(" + scale + ")"});

				}
				radians += spacing;
			}
			// Turn display back on.					
			this.innerWrapper.style.display = 'block';
			
			// If we have a preceptable change in rotation then loop again next frame.
			if ( absChange >= 0.001 )
			{				
				this.controlTimer = setTimeout( function(){context.updateAll();},this.timeDelay);		
			}else
			{
				// Otherwise just stop completely.
				this.stop();
			}
		}; // END updateAll		
		
		// Create an Item object for each image	
//		func = function(){return;ctx.updateAll();} ;

		// Check if images have loaded. We need valid widths and heights for the reflections.
		this.checkImagesLoaded = function()
		{
			var	i;
			var parent;
			
			for(i=0;i<images.length;i++) {
				if (( (images[i].complete !== undefined) && (!images[i].complete)  ))
				{
					return;					
				}				
			}

			
                        $(options.bulletBox).append('<ul id="bullet"></ul>');
			$('#bullet').append('<li><img src="'+options.salesforceURL+'/images/bullet.png" alt="" id="bullet0"/></li>');
                        for(var i=(images.length-1);i>0;i--) {
                                $('#bullet').append('<li><img src="'+options.salesforceURL+'/images/bullet.png" alt="" id="bullet' + i + '"/></li>');
                        }


			for(i=0;i<images.length;i++) {								
				items.push( new Item( images[i], options ) );	
				$(images[i]).data('itemIndex',i);
			}
			// If all images have valid widths and heights, we can stop checking.			
			clearInterval(this.tt);
			this.showFrontText();
			this.autoRotate();	
			this.updateAll();
			
		};

		this.tt = setInterval( function(){ctx.checkImagesLoaded();},50);	
	}; // END Controller object
	
	// The jQuery plugin part. Iterates through items specified in selector and inits a Controller class for each one.
	$.fn.CloudCarousel = function(options) {
			
		this.each( function() {			
			
			options = $.extend({}, {
								reflHeight:0,
								reflOpacity:0.5,
								reflGap:0,
								minScale:0.5,
								xPos:0,
								yPos:0,
								xRadius:0,
								yRadius:0,
								bulletBox:null,
								altBox:null,
								titleBox:null,
								autoStart: null,
								FPS: 30,
								autoRotate: 'no',
								autoRotateDelay: 1000,
								speed:0.2,
								mouseWheel: false,
								bringToFront: false
			},options );									
			// Create a Controller for each carousel.	
			$(this).data('cloudcarousel', new Controller( this, $('.cloudcarousel',$(this)), options) );
		});				
		return this;
	};

})(jQuery);
