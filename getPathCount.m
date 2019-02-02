function getPathCount(algo,startSP,endSP,filePath)
%ͳ�Ʒ����·����
% 2012.12.20
%algo is ospf or spef  getPathCount('spef',97,168,'scale_15_5')

num_node=11;



%�仯��ԴĿ�Ķ���
%     Num_exchange_SD(:,:)=zeros(endSP,endSP);
%ĳ����������ĳ��ԴĿ���ϱ仯��·����
% Num_path_exchange_perSD(:,:,:,:)=zeros(endSP,endSP,num_node,num_node);
%  strRO���ÿһԴĿ�Ķ��е��������·��
% strRO=cell(endSP-startSP,num_node,num_node,100);
%ĳ������������ĳһԴĿ�ĶԼ�·����
path_count(:,:,:)=zeros(endSP-startSP+1,num_node,num_node);


PathCount_ospf=['abilene_' algo '_pathcount'];
RO_out = ['./result/' filePath '/PathCount/' PathCount_ospf '.txt'];
RO_fid = fopen(RO_out, 'wt');

PathCount_spef=['abilene_' algo '_pathcount'];
perSD_RO_out = ['./result/' filePath '/PathCount/' PathCount_spef '.txt'];
perSD_RO_fid = fopen(perSD_RO_out, 'wt');

%������һ�Σ�����Ҫ�����ݴ���strRO��path_count��
for index=startSP:endSP
    strIndex=num2str(index);
    
    SinglePathCount=0;%ֻ������1��·����ԴĿ����
    DoublePathCount=0;%ֻ������2��·����ԴĿ����
    TreblePathCount=0;%ֻ������3��·����ԴĿ����
    MultiPathCount=0;%������3������·����ԴĿ����
    TotalPathCount=0;%���ĳ���㷨�������·����
    
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
                [i_path,j_path]=size(m.CSD(i).SD(j).ShortestPathRecord);%ͬһԴĿ�ĶԼ�·����
                
                SourNode=m.CSD(i).SD(j).SourNode;
                DestNode=m.CSD(i).DestNode;
                
                path_count(index,SourNode,DestNode)=i_path;%ĳ������������ĳһԴĿ�ĶԼ�·����
                %tmp_path_count(index,SourNode,DestNode)=path_count(index,SourNode,DestNode);
                
                if(i_path==1)
                    SinglePathCount=SinglePathCount+1;%ֻ������1��·����ԴĿ����
                elseif(i_path==2)
                    DoublePathCount=DoublePathCount+1;%ֻ������2��·����ԴĿ����
                elseif(i_path==3)
                    TreblePathCount=TreblePathCount+1;%ֻ������3��·����ԴĿ����
                elseif(i_path>3)
                    MultiPathCount=MultiPathCount+1;%������3������·����ԴĿ����
                else
                    disp('error in i_path');
                end
                
                if(i_path>0)
                    TotalPathCount=TotalPathCount+i_path;%���ĳ���㷨�������·����
                end
            end
        end
        
        %��·����  1��·��   2��·��  3��·��  ����·��
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
                [i_path,j_path]=size(m.OPSD(i).SD(j).ShortestPathRecord);%ͬһԴĿ�ĶԼ�·����
                
                SourNode=m.OPSD(i).SD(j).SourNode;
                DestNode=m.OPSD(i).DestNode;
                
                path_count(index,SourNode,DestNode)=i_path;%ĳ������������ĳһԴĿ�ĶԼ�·����
                if(i_path==1)
                    SinglePathCount=SinglePathCount+1;%ֻ������1��·����ԴĿ����
                elseif(i_path==2)
                    DoublePathCount=DoublePathCount+1;%ֻ������2��·����ԴĿ����
                elseif(i_path==3)
                    TreblePathCount=TreblePathCount+1;%ֻ������3��·����ԴĿ����
                elseif(i_path>3)
                    MultiPathCount=MultiPathCount+1;%������3������·����ԴĿ����
                else
                    disp('error in i_path');
                end
                
                 if(i_path>0)
                     TotalPathCount=TotalPathCount+i_path;%���ĳ���㷨�������·����
                end
                
            end
        end
        
        %TotalPathCount=SinglePathCount+2*DoublePathCount+3*TreblePathCount;
        
        %��·����  1��·��   2��·��  3��·��  ����·��
        fprintf(perSD_RO_fid,  '%d %d %d %d %d',TotalPathCount,SinglePathCount,DoublePathCount,TreblePathCount,MultiPathCount);
        fprintf(perSD_RO_fid, '\n');
       
    end
   
end


    fclose(RO_fid);

    fclose(perSD_RO_fid);


end

