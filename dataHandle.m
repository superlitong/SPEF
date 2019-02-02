function dataHandle()
%input:the number of traffic metrix


getPathCount('ospf',97,168,'scale_01_5');
getPathCount('ospf',97,168,'scale_35_5');
getPathCount('ospf',33,56,'scale_35_15');
getPathCount('ospf',17,28,'scale_35_30');
getPathCount('ospf',9,14,'scale_35_60');
getPathCount('ospf',6,9,'scale_35_90');
getPathCount('ospf',5,7,'scale_35_120');
getPathCount('spef',97,168,'scale_01_5');
getPathCount('spef',97,168,'scale_35_5');
getPathCount('spef',33,56,'scale_35_15');
getPathCount('spef',17,28,'scale_35_30');
getPathCount('spef',9,14,'scale_35_60');
getPathCount('spef',6,9,'scale_35_90');
getPathCount('spef',5,7,'scale_35_120');





getPathofTM('spef',97,168,'scale_01_5');
getPathofTM('spef',97,168,'scale_35_5');
getPathofTM('spef',33,56,'scale_35_15');
getPathofTM('spef',17,28,'scale_35_30');
getPathofTM('spef',9,14,'scale_35_60');
getPathofTM('spef',6,9,'scale_35_90');
getPathofTM('spef',5,7,'scale_35_120');


for index=97:168
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_01_5');
    OPSD2txt(strIndex,'scale_01_5');
end

for index=97:168
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_35_5');
    OPSD2txt(strIndex,'scale_35_5');
end

for index=33:56
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_35_15');
    OPSD2txt(strIndex,'scale_35_15');
end

for index=17:28
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_35_30');
    OPSD2txt(strIndex,'scale_35_30');
end

for index=9:14
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_35_60');
    OPSD2txt(strIndex,'scale_35_60');
end

for index=6:9
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_35_90');
    OPSD2txt(strIndex,'scale_35_90');
end

for index=5:7
    strIndex=num2str(index);
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    CSD2txt(strIndex,'scale_35_120');
    OPSD2txt(strIndex,'scale_35_120');
end













