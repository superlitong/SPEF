function OPESD2txt(strTMIndex)

    pre = ['TrafPath' strTMIndex];
    fp = [pre '.mat'];
    m = load(fp);
   
 
    
    ShortPath='abilene_ShortPath_peft';
    SP_out = ['./result/' ShortPath strTMIndex '.txt'];
    SP_fid = fopen(SP_out, 'wt');
    
 %   fprintf(SP_fid, '##�������� ���·��\n');
%     fprintf(SR_fid, '##Դ�ڵ� Ŀ�Ľڵ� COST �������� ���·��\n');
     
    [rsize,csize] = size(m.TrafPath);
    for i=1:rsize
         
    
       %Դ��Ŀ�ģ���һȨ��?����������,���·��   
      
      fprintf(SP_fid, '%s \n%s',num2str(m.TrafPath(i,2:11)),m.TrafPath(i,1));
       fprintf(SP_fid, '\n');
     
    end 
   
    fclose(SP_fid);
    disp([strTMIndex ' OK']);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end   
