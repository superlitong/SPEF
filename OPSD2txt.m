function OPSD2txt(strTMIndex,filePath)

   
  SplittingRatio='abilene_spef';
 SR_out = ['./result/' filePath '/' SplittingRatio strTMIndex '.txt'];
 SR_fid = fopen(SR_out, 'wt');
    
    ShortPath='abilene_ShortPath_spef';
    SP_out = ['./result/' filePath '/' ShortPath strTMIndex '.txt'];
    SP_fid = fopen(SP_out, 'wt');
    
    
    pre = 'OPSD';
   % fp = ['./result/' filePath '/' pre strTMIndex '.mat'];
     fp = [pre strTMIndex '.mat'];
    m = load(fp);
    
 %   fprintf(SP_fid, '##流量分配 最短路径\n');
%     fprintf(SR_fid, '##源节点 目的节点 COST 流量分配 最短路径\n');
     
    [rsize,csize] = size(m.OPSD);
    for i=1:rsize
        [sdi,sdj]=size( m.OPSD(i).SD);
    for j=1:sdi 
      [i_traffic,j_traffic]=size(m.OPSD(i).SD(j).Traffic);
       [i_cost,j_cost]=size(m.OPSD(i).SD(j).ShortestPathRecord);
     [i_path,j_path]=size(m.OPSD(i).SD(j).ShortestPathRecord);
    
    for k=1:i_path  
     %流量分配，最短路径
     
   fprintf(SP_fid, '%s \n%f',num2str(m.OPSD(i).SD(j).ShortestPathRecord(k,:)),m.OPSD(i).SD(j).Traffic(1,k));
       fprintf(SP_fid, '\n');    
    
       %源，目的，第一权重?，流量分配,最短路径   
      
      fprintf(SR_fid, '%d %d %f %f * %s ',m.OPSD(i).SD(j).SourNode,m.OPSD(i).DestNode,m.OPSD(i).SD(j).Cost(1,k),m.OPSD(i).SD(j).Traffic(1,k),num2str(m.OPSD(i).SD(j).ShortestPathRecord(k,:)));
       fprintf(SR_fid, '\n');
     end
        end
    end 
    fclose(SR_fid);
    fclose(SP_fid);
    disp([pre ' OK']);
    
