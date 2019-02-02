function getPathCount(algo,startSP,endSP,filePath)
%统计分配的路径数
% 2012.12.20
%algo is ospf or spef  getPathCount('spef',97,168,'scale_15_5')

num_node=11;



%变化的源目的对数
%     Num_exchange_SD(:,:)=zeros(endSP,endSP);
%某个流量矩阵某个源目的上变化的路径数
% Num_path_exchange_perSD(:,:,:,:)=zeros(endSP,endSP,num_node,num_node);
%  strRO存放每一源目的对中的所有最短路径
% strRO=cell(endSP-startSP,num_node,num_node,100);
%某个流量矩阵中某一源目的对间路径数
path_count(:,:,:)=zeros(endSP-startSP+1,num_node,num_node);


PathCount_ospf=['abilene_' algo '_pathcount'];
RO_out = ['./result/' filePath '/PathCount/' PathCount_ospf '.txt'];
RO_fid = fopen(RO_out, 'wt');

PathCount_spef=['abilene_' algo '_pathcount'];
perSD_RO_out = ['./result/' filePath '/PathCount/' PathCount_spef '.txt'];
perSD_RO_fid = fopen(perSD_RO_out, 'wt');

%先运行一次，把需要的数据存在strRO和path_count里
for index=startSP:endSP
    strIndex=num2str(index);
    
    SinglePathCount=0;%只分配了1条路径的源目的数
    DoublePathCount=0;%只分配了2条路径的源目的数
    TreblePathCount=0;%只分配了3条路径的源目的数
    MultiPathCount=0;%分配了3条以上路径的源目的数
    TotalPathCount=0;%针对某种算法分配的总路径数
    
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    
    if(strcmp(algo,'ospf'))
        pre = ['./result/' filePath '/CSD'];
        
        
        fp = [pre strIndex '.mat'];
        m= load(fp);
        
        
        [rsize,csize] = size(m.CSD);
        
        
        for i=1:rsize
            [sdi,sdj]=size( m.CSD(i).SD);
            for j=1:sdi
                
                [i_traffic,j_traffic]=size(m.CSD(i).SD(j).Traffic);
                [i_path,j_path]=size(m.CSD(i).SD(j).ShortestPathRecord);%同一源目的对间路径数
                
                SourNode=m.CSD(i).SD(j).SourNode;
                DestNode=m.CSD(i).DestNode;
                
                path_count(index,SourNode,DestNode)=i_path;%某个流量矩阵中某一源目的对间路径数
                %tmp_path_count(index,SourNode,DestNode)=path_count(index,SourNode,DestNode);
                
                if(i_path==1)
                    SinglePathCount=SinglePathCount+1;%只分配了1条路径的源目的数
                elseif(i_path==2)
                    DoublePathCount=DoublePathCount+1;%只分配了2条路径的源目的数
                elseif(i_path==3)
                    TreblePathCount=TreblePathCount+1;%只分配了3条路径的源目的数
                elseif(i_path>3)
                    MultiPathCount=MultiPathCount+1;%分配了3条以上路径的源目的数
                else
                    disp('error in i_path');
                end
                
                if(i_path>0)
                    TotalPathCount=TotalPathCount+i_path;%针对某种算法分配的总路径数
                end
            end
        end
        
        %总路径数  1条路径   2条路径  3条路径  多条路径
        fprintf(RO_fid, '%d %d %d %d %d',TotalPathCount,SinglePathCount,DoublePathCount,TreblePathCount,MultiPathCount);
        fprintf(RO_fid, '\n');
        
        
    elseif(strcmp(algo,'spef'))
        pre = ['./result/' filePath '/OPSD'];
        
        fp = [pre strIndex '.mat'];
        m= load(fp);
        
        [rsize,csize] = size(m.OPSD);
        
        %  strRO=cell(endSP-startSP,rsize,rsize,100);
        
        for i=1:rsize
            [sdi,sdj]=size( m.OPSD(i).SD);
            for j=1:sdi
                
                [i_traffic,j_traffic]=size(m.OPSD(i).SD(j).Traffic);
                %   [i_cost,j_cost]=size(m.OPSD(i).SD(j).ShortestPathRecord);
                [i_path,j_path]=size(m.OPSD(i).SD(j).ShortestPathRecord);%同一源目的对间路径数
                
                SourNode=m.OPSD(i).SD(j).SourNode;
                DestNode=m.OPSD(i).DestNode;
                
                path_count(index,SourNode,DestNode)=i_path;%某个流量矩阵中某一源目的对间路径数
                if(i_path==1)
                    SinglePathCount=SinglePathCount+1;%只分配了1条路径的源目的数
                elseif(i_path==2)
                    DoublePathCount=DoublePathCount+1;%只分配了2条路径的源目的数
                elseif(i_path==3)
                    TreblePathCount=TreblePathCount+1;%只分配了3条路径的源目的数
                elseif(i_path>3)
                    MultiPathCount=MultiPathCount+1;%分配了3条以上路径的源目的数
                else
                    disp('error in i_path');
                end
                
                 if(i_path>0)
                     TotalPathCount=TotalPathCount+i_path;%针对某种算法分配的总路径数
                end
                
            end
        end
        
        %TotalPathCount=SinglePathCount+2*DoublePathCount+3*TreblePathCount;
        
        %总路径数  1条路径   2条路径  3条路径  多条路径
        fprintf(perSD_RO_fid,  '%d %d %d %d %d',TotalPathCount,SinglePathCount,DoublePathCount,TreblePathCount,MultiPathCount);
        fprintf(perSD_RO_fid, '\n');
       
    end
   
end


    fclose(RO_fid);

    fclose(perSD_RO_fid);


end

