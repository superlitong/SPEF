function OPISD2txt(strTMIndex)

    pre = 'OPISD';
    fp = [pre strTMIndex '.mat'];
    m = load(fp);
   
    SplittingRatio='abilene_spef_I';
    SR_out = ['./result/abilene/' SplittingRatio strTMIndex '.txt'];
    SR_fid = fopen(SR_out, 'wt');
    
    ShortPath='abilene_ShortPath_spef_I';
    SP_out = ['./result/abilene/' ShortPath strTMIndex '.txt'];
    SP_fid = fopen(SP_out, 'wt');
    
 %   fprintf(SP_fid, '##流量分配 最短路径\n');
 %    fprintf(SR_fid, '##源节点 目的节点 COST 流量分配 最短路径\n');
     
    [rsize,csize] = size(m.OPISD);
    for i=1:rsize
        [sdi,sdj]=size( m.OPISD(i).SD);
    for j=1:sdi 
      [i_traffic,j_traffic]=size(m.OPISD(i).SD(j).Traffic);
       [i_cost,j_cost]=size(m.OPISD(i).SD(j).ShortestPathRecord);
     [i_path,j_path]=size(m.OPISD(i).SD(j).ShortestPathRecord);
    
    for k=1:i_path  
     %流量分配，最短路径
     
   fprintf(SP_fid, '%s \n%f',num2str(m.OPISD(i).SD(j).ShortestPathRecord(k,:)),m.OPISD(i).SD(j).Traffic(1,k));
       fprintf(SP_fid, '\n');    
    
       %源，目的，第一权重?，流量分配,最短路径   
      
      fprintf(SR_fid, '%d %d %f %f * %s ',m.OPISD(i).SD(j).SourNode,m.OPISD(i).DestNode,m.OPISD(i).SD(j).Cost(1,k),m.OPISD(i).SD(j).Traffic(1,k),num2str(m.OPISD(i).SD(j).ShortestPathRecord(k,:)));
      fprintf(SR_fid, '\n');
     end
        end
    end 
    fclose(SR_fid);
    fclose(SP_fid);
    disp([pre ' OK']);
    
