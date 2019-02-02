function [xPathFT,nece_capacity,Weight_LinkUtilization]=TE_lp(type,obj)
% clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program solves the problem of TE with objective function MML and pice-linear aapproximation of M/M/1 delay proposed by B. Fortz et al through linprog in matlab optimization tool.
% Today is Sep. 26, 2009

%%
global B c S DemandMatrix A x H IngressEgressNumberPath DemandMatrixDestination

%%

%[B,c,S,DemandMatrix,A,x,H,IngressEgressNumberPath,DemandMatrixDestination] = topologyTM(topo);
[J,R] = size(A);
N=size(B,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve the TE path-based and link-based with the objective function ML and FT through linprog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (strcmp(type,'path')) % path-based TE
    fPath=zeros(J+R,1);
    AeqPath= [eye(J,J) A;zeros(S,J) H]; % s+Ay=c, Hy=x;
    beqPath= [c;x];
    y0Path = 0.01 * max(c) * ones(R,1);
    s0Path = c - A * y0Path;    
    if (strcmp(obj,'ML'))%  TE path-based with maximum link utilization 
        fPathML=[fPath; 1];
        AeqPathML=[AeqPath zeros(J+S,1)];        
        beqPathML = beqPath;
        
        AieqPathML=[-diag(1./c)  zeros(J,R)  -ones(J,1)];
        bieqPathML=-ones(J,1);
        
        lbPathML = zeros(J+R+1,1);
        ubPathML = max(c)*ones(J+R+1,1);
        
        alphaPathML=max(1-s0Path./c);
        sya0ML = [s0Path;y0Path;alphaPathML];
        [xPathML,fvalPathML,exitflagPathML,outputPathML,lambdaPathML]=linprog(fPathML,AieqPathML,bieqPathML,AeqPathML,beqPathML,lbPathML,ubPathML,sya0ML);
        s=xPathML(1:J);
        y=xPathML(J+1:J+R); y=y';
        Weight=abs(lambdaPathML.eqlin(1:J));        
    elseif (strcmp(obj, 'FT')) %  TE path-based with objective function proposed by B. Fortz et al 
        fPathFT=[fPath; ones(J,1)];
        AeqPathFT=[AeqPath zeros(J+S,J)];        
        beqPathFT = beqPath;
        
        slope=[-1 -3 -10 -70 -500 -5000]'; 
        rightV=[-1; -7/3; -14/3; -32/3; -32/3; 1318/3];
        AieqPathFT=zeros(6*J, J+R+J);
        bieqPathFT=zeros(6*J,1);
        for j=1:J
            AieqPathFT(6*(j-1)+1:6*j, j)=slope;
            AieqPathFT(6*(j-1)+1:6*j,J+R+j)=-ones(6,1);
            bieqPathFT(6*(j-1)+1:6*j)=rightV*c(j);
        end
        
        lbPathFT = zeros(J+R+J,1);
        ubPathFT = max(c)*ones(J+R+J,1);%100*
        
        alphaPathFT=zeros(J,1);
        for j=1:J
            alphaPathFT(j)=max(slope*s0Path(j)+rightV*c(j));
        end
        sya0FT = [s0Path;y0Path;alphaPathFT];
        [xPathFT,fvalPathFT,exitflagPathFT,outputPathFT,lambdaPathFT]=linprog(fPathFT,AieqPathFT,bieqPathFT,AeqPathFT,beqPathFT,lbPathFT,ubPathFT,sya0FT);
        s=xPathFT(1:J);
        y=xPathFT(J+1:J+R); y=y';
        Weight=abs(lambdaPathFT.eqlin(1:J));  
        
    end
elseif (strcmp(type,'link'))%   link-based TE
    fLink=zeros(S*J+J,1);
    AA= zeros(J,S*J);
    for j=1:J
        for s=1:S
            AA(j,(s-1)*J+j) = 1;
        end
    end
    AeqCapcity= [eye(J,J) AA];  beqCapcity=c; % s+sum_s f^s=c    
    AeqConversation =zeros(S*N, J+S*J); beqConversation =zeros(S*N,1);
    for l=1:S
        AeqConversation ((l-1)*N+1:l*N, J+(l-1)*J+1:J+l*J)=B; 
        beqConversation ((l-1)*N+1:l*N) = DemandMatrix(:,l);
    end
    AeqLink = [AeqCapcity; AeqConversation]; % s+sum_s f^s=c, Bf^s=d^s
    beqLink = [beqCapcity; beqConversation];

    f0Link = 0.01 * max(c) * ones(S*J,1);
    s0Link = c - AA * f0Link;    
    if (strcmp(obj,'ML'))%  TE link-based with maximum link utilization 
        fLinkML=[fLink; 1];
        AeqLinkML=[AeqLink zeros(J+N*S,1)];        
        beqLinkML = beqLink;
    
        AieqLinkML=[-diag(1./c)  zeros(J,S*J)  -ones(J,1)];
        bieqLinkML=-ones(J,1);
    
        lbLinkML = zeros(J+J*S+1,1);
        ubLinkML = max(c)*ones(J+J*S+1,1);
     
        alphaLinkML=max(1-s0Link./c);
        sfa0ML = [s0Link;f0Link;alphaLinkML];
        [xLinkML,fvalLinkML,exitflagLinkML,outputLinkML,lambdaLinkML]=linprog(fLinkML,AieqLinkML,bieqLinkML,AeqLinkML,beqLinkML,lbLinkML,ubLinkML,sfa0ML);
        s=xLinkML(1:J);
        f=xLinkML(J+1:J+S*J); f=f';
        Weight=abs(lambdaLinkML.eqlin(1:J));        
    elseif (strcmp(obj, 'FT')) %  TE link-based with objective function proposed by B. Fortz et al 
        fLinkFT=[fLink; ones(J,1)];
        AeqLinkFT=[AeqLink zeros(J+N*S,J)];        
        beqLinkFT = beqLink;
    
        slope=[-1 -3 -10 -70 -500 -5000]'; 
        rightV=[-1; -7/3; -14/3; -32/3; -32/3; 1318/3];
        AieqLinkFT=zeros(6*J, J+S*J+J);
        bieqLinkFT=zeros(6*J,1);
        for j=1:J
            AieqLinkFT(6*(j-1)+1:6*j, j)=slope;
            AieqLinkFT(6*(j-1)+1:6*j,J+S*J+j)=-ones(6,1);
            bieqLinkFT(6*(j-1)+1:6*j)=rightV*c(j);
        end
    
        lbLinkFT = zeros(J+S*J+J,1);
        ubLinkFT = 100*max(c)*ones(J+S*J+J,1);
        
        alphaLinkFT=zeros(J,1);
        for j=1:J
            alphaLinkFT(j)=max(slope*s0Link(j)+rightV*c(j));
        end
        sfa0FT = [s0Link;f0Link;alphaLinkFT];
        [xLinkFT,fvalLinkFT,exitflagLinkFT,outputLinkFT,lambdaLinkFT]=linprog(fLinkFT,AieqLinkFT,bieqLinkFT,AeqLinkFT,beqLinkFT,lbLinkFT,ubLinkFT,sfa0FT);
        s=xLinkFT(1:J);
        f=xLinkFT(J+1:J+S*J); f=f';
        Weight=abs(lambdaLinkFT.eqlin(1:J));         
    end
end

 
LinkUtilization = 1-s./c;
nece_capacity = LinkUtilization.*c;
Weight=Weight;
PathPrice=Weight'*A;
LinkUtilization = LinkUtilization';
Weight = Weight';
Weight_LinkUtilization=[Weight ;LinkUtilization];


indexP1=0;indexP2=0;
for s=1:S
    indexP2=indexP2+IngressEgressNumberPath(s,3);
    if (strcmp(type,'path')) % path-based TE
        yLinks=y(indexP1+1:indexP2);              
    elseif (strcmp(type,'link')) % link-based TE
        fs=f((s-1)*J+1:s*J)
        yLinks=zeros(1,IngressEgressNumberPath(s,3));
        for sr=1:IngressEgressNumberPath(s,3)
            ysr=fs(find(A(:,indexP1+sr)));
            yLinks(sr)=min(ysr);
        end
    end
    Price=PathPrice(indexP1+1:indexP2);  
    Price_y=[Price; yLinks]
    indexP1=indexP2;
end
%clear ans;