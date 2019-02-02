function [Phi, g, H] = objTE(f,beta,J)
LinkSpareCapacity = f(1:J);
VaribleNum=length(f);
Phi = 0;
g=zeros(VaribleNum,1);
H=zeros(VaribleNum,VaribleNum);
for j = 1:J
    if (beta == 1)
        if  (LinkSpareCapacity(j)<=0)
            Phi=Phi-inf
        else
            Phi = Phi + log(LinkSpareCapacity(j));
        end
    else
        Phi = Phi + (LinkSpareCapacity(j))^(1 - beta)/(1 - beta);
    end
    g(j)=(LinkSpareCapacity(j))^( - beta);
    H(j,j)=(-beta)*(LinkSpareCapacity(j))^( - beta-1);
end

Phi = -Phi;
g=-g;
H=-H;