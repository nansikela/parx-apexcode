function AlignToCenter(Element)
		{
			var availableHeight = 0;
			var availableWidth = 0;
			if (Element.ownerDocument)
			{
				var docElement = Element.ownerDocument.documentElement;
				availableHeight = parseInt(docElement.clientHeight);
				if (availableHeight == "NaN") availableHeight = 0;
		
				availableWidth = parseInt(docElement.clientWidth);
				if (availableWidth == "NaN") availableWidth = 0;
			}
		
			if (availableHeight == 0 || availableHeight == "NaN")
				availableHeight = window.screen.availHeight - 200;
			if (availableWidth == 0 || availableWidth == "NaN")
				availableWidth = window.screen.availWidth - 100;
		
			var msgBoxTop = parseInt((availableHeight - parseInt(Element.clientHeight))/2);
			var msgBoxleft = parseInt((availableWidth - parseInt(Element.style.width))/2);

		
			//if (msgBoxTop == "NaN" || msgBoxTop == 0)
			//	msgBoxBottom = 40;
			msgBoxBottom = 400;
			//if(Element.scrollTop > 1000)
			//	msgBoxBottom = parseInt((availableHeight - parseInt(Element.clientHeight))/2);
				
			Element.style.left = msgBoxleft + "px";
			Element.style.bottom = msgBoxBottom + "px";
		}