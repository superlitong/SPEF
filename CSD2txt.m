function CSD2txt(strTMIndex,filePath)

%StrFileOut=strcat(FileOutPath,FileOutName)

   
 SplittingRatio='abilene_ospf';
 SR_out = ['./result/' filePath '/' SplittingRatio strTMIndex '.txt'];
 SR_fid = fopen(SR_out, 'wt');
    
    ShortPath='abilene_ShortPath_ospf';
    SP_out = ['./result/' filePath '/' ShortPath strTMIndex '.txt'];
    SP_fid = fopen(SP_out, 'wt');
    
     pre = 'CSD';
  %  fp = ['./result/' filePath '/' pre strTMIndex '.mat'];
     fp = [pre strTMIndex '.mat'];
    m = load(fp);
    
%       fprintf(SP_fid, '##�������� ���·��\n');
%     fprintf(SR_fid, '##Դ�ڵ� Ŀ�Ľڵ� COST �������� ���·��\n');
    
    [rsize,csize] = size(m.CSD);
    for i=1:rsize
        [sdi,sdj]=size( m.CSD(i).SD);
    for j=1:sdi

      [i_traffic,j_traffic]=size(m.CSD(i).SD(j).Traffic);
       [i_cost,j_cost]=size(m.CSD(i).SD(j).ShortestPathRecord);
     [i_path,j_path]=size(m.CSD(i).SD(j).ShortestPathRecord);
    
    for k=1:i_path  
     %�������䣬���·��
   fprintf(SP_fid, '%s \n%f',num2str(m.CSD(i).SD(j).ShortestPathRecord(k,:)),m.CSD(i).SD(j).Traffic(1,k));
       fprintf(SP_fid, '\n');    
    
       %Դ��Ŀ�ģ���һȨ��?����������,���·��         
      fprintf(SR_fid, '%d %d %d %f * %s ',m.CSD(i).SD(j).SourNode,m.CSD(i).DestNode,m.CSD(i).SD(j).Cost(1,k),m.CSD(i).SD(j).Traffic(1,k),num2str(m.CSD(i).SD(j).ShortestPathRecord(k,:)));
       fprintf(SR_fid, '\n');
     end
        end
    end 
    fclose(SR_fid);
    fclose(SP_fid);
    disp([pre ' OK']);
    
