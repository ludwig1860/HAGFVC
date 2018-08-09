function [ img_rgb3 ] = TwoPercentLinStch( img_rgb )

	r = img_rgb( : , : , 1 );  
	
	g = img_rgb( : , : , 2 );  
	
	b = img_rgb( : , : , 3 );  
	
	[ ra , rb ] = hist( r( : ) , 0 : 1 : 255 );
	
	pl = ra / sum( ra );  pls = 0;  j = 1;
	
	while pls < 0.02
		
		pls = pls + pl( j ) * 1;
		
		j = j + 1;
		
	end
	
	rb1 = rb( j - 1 );
	
	while pls < 0.98
	
		pls = pls + pl( j ) * 1;
		
		j = j + 1;
		
	end
	
	rb2 = rb( j - 1 );
	
	if rb1 == rb2
	
		rb2 = rb2 + 1;
		
	end
	rad = imadjust( r , [ rb1 / 255 rb2 / 255] ,[ 0 1 ] , 1 );
	
	clear r ra rb rb1 rb2 pl pls j;
	
	[ga,gb]=hist(g(:),0:1:255);
	
	pl=ga/sum(ga);
	
	pls=0;
	
	j=1;
	
	while pls<0.02
	
		pls=pls+pl(j)*1;
		
		j=j+1;
		
	end
	
	gb1=gb(j-1);

	while pls<0.98
	
		pls=pls+pl(j)*1;
		
		j=j+1;
		
	end
	
	gb2=gb(j-1);

	if gb1==gb2
	
		gb2=gb2+1;
		
	end

	gad=imadjust(g,[gb1/255 gb2/255],[0 1],1);
	
	clear g ga gb gb1 gb2 pl pls j;

	[ba,bb]=hist(b(:),0:1:255);
	
	pl=ba/sum(ba);
	
	pls=0;j=1;
	
	while pls<0.02
	
		pls=pls+pl(j)*1;
		
		j=j+1;
		
	end
	
	bb1=bb(j-1);

	while pls<0.98
	
		pls=pls+pl(j)*1;
		
		j=j+1;
	end
	bb2=bb(j-1);

	if bb1==bb2
	
		bb2=bb2+1;
		
	end

	bad=imadjust(b,[bb1/255 bb2/255],[0 1],1);
	
	clear b ba bb bb1 bb2 pl pls j;

	rad=im2double(rad); 
	
	gad=im2double(gad);
	
	bad=im2double(bad);
	
	rgb=cat(3,rad,gad,bad);
	
	img_rgb3 = max(min(rgb, 1), 0);
	
	clear rad gad bad rgb;

end

