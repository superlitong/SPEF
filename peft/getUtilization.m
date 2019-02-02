function getUtilization(startSP,endSP,filePath)
%链路利用率 getUtilization(97,168,'scale_01_5');

num_node=11;
num_link=28;








for index=startSP:endSP
    strIndex=num2str(index);
    
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    
    pre = ['./result/' filePath '/TrafPath'];
    
    fp = [pre strIndex '.mat'];
    m= load(fp);
    
    
    [rsize,csize] = size(m.TrafPath);
  
    LinkTraffic(:,:)=zeros(num_node,num_node);
    
    for i=1:rsize
        
        for j=3:11
            if  m.TrafPath(i,j)~=0
                SNode=m.TrafPath(i,j-1);
                DNode=m.TrafPath(i,j);
                LinkTraffic(SNode,DNode)=LinkTraffic(SNode,DNode)+m.TrafPath(i,1);
            end
        end
    end
    
    LinkUtilization(:,:)=zeros(2,num_link);
    LinkUtilization(1,:)=10;
    
    n=1;
        for i=1:11
        for j=1:11
        
            if(LinkTraffic(i,j)~=0)
                LinkUtilization(2,n)=LinkTraffic(i,j);
                
                
                n=n+1;
            end
        end
    end
    
    
    matFileName='';
    matFileName=strcat('LinkUtilization',strIndex);
    save(matFileName, 'LinkUtilization');
    
    
    
end







end
