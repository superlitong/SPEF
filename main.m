function main(startnum,endnum)
%input:the number of traffic metrix

for index=startnum:endnum
   strIndex=num2str(index); 
   if index<10
       strIndex=['00' strIndex];
   elseif index<100
       strIndex=['0' strIndex];
   end
   
   testTE(strIndex);
   tipsstr=sprintf('Traffic metrix %d is completed!',index);
    disp(tipsstr);
    
    CSD2txt(strIndex,'scale_15_120');
     OPSD2txt(strIndex,'scale_15_120');
 % %    OPISD2txt(strIndex);
end

