function getPathofTM(algo,startSP,endSP,filePath)
%Routing Oscillation
% 2012.12.20
%algo is ospf or spef

num_node=11;

RoutingOscillation=['abilene_' algo '_RO'];
RO_out = ['./result/' filePath '/RoutingOscillation/' RoutingOscillation '.txt'];
RO_fid = fopen(RO_out, 'wt');

RoutingOscillation_perSD=['abilene_' algo '_RO_perSD'];
perSD_RO_out = ['./result/' filePath '/RoutingOscillation/' RoutingOscillation_perSD '.txt'];
perSD_RO_fid = fopen(perSD_RO_out, 'wt');

%变化的源目的对数
Num_exchange_SD(:,:)=zeros(endSP,endSP);
%某个流量矩阵某个源目的上变化的路径数
Num_path_exchange_perSD(:,:,:,:)=zeros(endSP,endSP,num_node,num_node);
%  strRO存放每一源目的对中的所有最短路径
strRO=cell(endSP,num_node,num_node,10,10);
%某个流量矩阵中某一源目的对间路径数
path_count(:,:,:)=zeros(endSP,num_node,num_node);
Num_path_exchange_perSD_metrix=zeros(endSP-startSP+1,endSP-startSP+1);



%先运行一次，把需要的数据存在strRO和path_count里
for index=startSP:endSP
    strIndex=num2str(index);
    
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    if(strcmp(algo,'peft'))
        pre = ['./result/' filePath '/TrafPath'];
    elseif(strcmp(algo,'spef'))
        pre = ['./result/' filePath '/OPSD'];
    end
    fp = [pre strIndex '.mat'];
    m= load(fp);
    
    
    [rsize,csize] = size(m.TrafPath);
    
    %  先得到路径数
    for i=1:rsize
        SourNode=m.TrafPath(i,2);
        for j=2:11
            if  m.TrafPath(i,j)==0
                DestNode=m.TrafPath(i,j-1);
                break;
            elseif j==11
                DestNode=m.TrafPath(i,11);
            end
        end
        %某个流量矩阵中某一源目的对间路径数
        path_count(index,SourNode,DestNode)=path_count(index,SourNode,DestNode)+1;
        
    end
    
    
    
    %再运行一次，得到路径
   k_metrx=ones(11,11);
    for i=1:rsize
        SourNode=m.TrafPath(i,2);
        for j=2:11
            if  m.TrafPath(i,j)==0
                DestNode=m.TrafPath(i,j-1);
                break;
            elseif j==11
                DestNode=m.TrafPath(i,11);
            end
        end
       % for k=1:path_count(index,SourNode,DestNode)
            %  strRO存放每一源目的对中的所有最短路径
        
            strRO(index,SourNode,DestNode,k_metrx(SourNode,DestNode))=mat2cell(m.TrafPath(i,2:11));
      %  end
       k_metrx(SourNode,DestNode)=k_metrx(SourNode,DestNode)+1;
    end
    
end




%第二次循环，开始处理数据。这里再运行一次是为了保证取的数据顺序与第一次运行时一致。

for index=startSP:endSP
    
    sum_path_exchange=0;%一个流量矩阵，所有源目的对路径变化总和
    
    for SourNode=1:11
        for DestNode=1:11
            if SourNode~=DestNode&&path_count(index,SourNode,DestNode)~=0
                if index>startSP
                    N0=0;   %在比较两个流中同一源目的之间路径中，用来计数路径相同的条数
                    for kk=1:path_count(index,SourNode,DestNode)
                        for kkk=1:path_count(index-1,SourNode,DestNode)
                            a=num2str(cell2mat(strRO(index,SourNode,DestNode,kk)));
                            b=num2str(cell2mat(strRO(index-1,SourNode,DestNode,kkk)));
                            if(strcmp(num2str(cell2mat(strRO(index,SourNode,DestNode,kk))),num2str(cell2mat(strRO(index-1,SourNode,DestNode,kkk)))))
                                N0=N0+1;
                            end
                        end
                    end
                    if ((N0~=path_count(index,SourNode,DestNode)||N0~=path_count(index-1,SourNode,DestNode))&&N0~=0)%如果前后路径数变了
                        Num_exchange_SD(index-1,index)=Num_exchange_SD(index-1,index)+1;         %变化的源目的对数目加1
                    end
                    
                    %某个流量矩阵某个源目的上变化的路径数=前后路径数的较大值-相同的路径数
                    Num_path_exchange_perSD(index-1,index,SourNode,DestNode)=max(path_count(index,SourNode,DestNode),path_count(index-1,SourNode,DestNode))-N0;
                    %流量矩阵编号 vs 流量矩阵编号：源-目的    路由路径变化的数目
                    %                 fprintf(perSD_RO_fid, '%d vs %d:%d-%d \n%d',index-1,index,SourNode,DestNode,Num_path_exchange_perSD(index-1,index,SourNode,DestNode));
                    %                 fprintf(perSD_RO_fid, '\n');
                    
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    sum_path_exchange=sum_path_exchange+Num_path_exchange_perSD(index-1,index,SourNode,DestNode);
                end
            end
            
         
          
        end
    end
       
    Num_path_exchange_perSD_metrix(index-startSP+1,index-startSP+2)=sum_path_exchange;
    
    if index>startSP
        fprintf(RO_fid, '%d',Num_exchange_SD(index-1,index));
        fprintf(RO_fid, '\n');
    end
     
end


% 
%  for SourNode=1:11
%         for DestNode=1:11
%             if SourNode~=DestNode&&path_count(97,SourNode,DestNode)~=0
%  
%  for kkk=1:path_count(97,SourNode,DestNode)
%                            
%                   fprintf(perSD_RO_fid, '%s',num2str(cell2mat(strRO(97,SourNode,DestNode,kkk))));  
%             fprintf(perSD_RO_fid, '\n ');
%                         end
%  
%  
%             end
%         end
%  end
 
for i=1:endSP-startSP+1
    for j=1:endSP-startSP+1
        fprintf(perSD_RO_fid, '%d ',Num_path_exchange_perSD_metrix(i,j));
        
    end
    fprintf(perSD_RO_fid, '\n');
end
% disp(path_count(:,:,:));

fclose(RO_fid);
fclose(perSD_RO_fid);



end
