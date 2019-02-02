function OPESD2txt(strTMIndex)

    pre = ['TrafPath' strTMIndex];
    fp = [pre '.mat'];
    m = load(fp);
   
 
    
    ShortPath='abilene_ShortPath_peft';
    SP_out = ['./result/' ShortPath strTMIndex '.txt'];
    SP_fid = fopen(SP_out, 'wt');
    
 %   fprintf(SP_fid, '##流量分配 最短路径\n');
%     fprintf(SR_fid, '##源节点 目的节点 COST 流量分配 最短路径\n');
     
    [rsize,csize] = size(m.TrafPath);
    for i=1:rsize
         
    
       %源，目的，第一权重?，流量分配,最短路径   
      
      fprintf(SP_fid, '%s \n%s',num2str(m.TrafPath(i,2:11)),m.TrafPath(i,1));
       fprintf(SP_fid, '\n');
     
    end 
   
    fclose(SP_fid);
    disp([strTMIndex ' OK']);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end   
