function outIM = imgContrastEnhance(inIM, blocksize, step)

%% 局部图像块分析，提取局部特征量，生成局部增强函数，并对该块进行增强，获取更精准的增强结果
inIM = double(inIM);

[m, n, s] = size(inIM);
outIM = zeros(m, n, s);
indexIM = zeros(m, n, s);

%设定图像分块大小/半块
if ~exist( 'blocksize', 'var')
    blocksize = 5; 
end

%%选择块移动的步伐
if ~exist( 'step', 'var')
    step = 5; 
end

for t = 1:s
    img  = inIM(:,:,t);
   for i = blocksize+1 :  step : m-blocksize
       for j =  blocksize+1 :  step: n-blocksize
           block = img(i-blocksize:i+blocksize, j-blocksize:j+blocksize);
            dealBlock = blockpdf(block);
            outIM(i-blocksize:i+blocksize, j-blocksize:j+blocksize, t) = outIM(i-blocksize:i+blocksize, j-blocksize:j+blocksize, t) + dealBlock;
            indexIM(i-blocksize:i+blocksize, j-blocksize:j+blocksize, t) = indexIM(i-blocksize:i+blocksize, j-blocksize:j+blocksize, t) + 1;
       end
   end
end

outIM = outIM ./ indexIM;

end

function  dealBlock = blockpdf(block)

m = 0;
c = 0;
dl = 0;

[x, y] = size(block);
dealBlock = zeros(x,y);
len = length(block(:));
hist = zeros(1,256);

for i =1:len
    value = block(i);
    hist(value+1) = hist(value+1)+1;
end

histpdf = hist/len;
maxvalue = max(block(:));

for i =1:maxvalue
    m = m+(i/maxvalue * histpdf(i));  %子块平均亮度
end

 
  
for i =1:maxvalue
    c = c+((1-m)^2 * histpdf(i));  %对比度c作为该区域的特征量
end

pdfMax = max(histpdf);
pdfMin = min(histpdf);

pdfl = pdfMax * ((histpdf - pdfMin ) ./ (pdfMax - pdfMin)) .^(1+sqrt(c));

if m>=180/255
    s = 1;
else
    s = -1;
end

for i =1:maxvalue
    dl = dl + pdfl(i)/sum(pdfl);
end

for i = 1:maxvalue+1
    fl(i) = maxvalue*(i/maxvalue)^(1 + s*sqrt(dl));
end

for i = 1:x
    for j = 1:y
        dealBlock(i,j) = fl(block(i,j)+1);
    end
end

end








