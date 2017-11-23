clear;close all;clc
tic;
if(yes_or_no("Do you have separate train and test data file"))
string1 = input('Input the train file name --->>  ','s');
DATA = load(string1);
DATA = DATA(1:10000,:);
DATA = DATA(randperm(rows(DATA)),:); %randomise the data
data = DATA;
string2 = input('Input the test file name --->>  ','s');
finaltestData = load(string2);
finaltestData = finaltestData(1:2000,:);
else
string = input('Input the data file name --->> ','s');
DATA = load(string);
DATA = DATA(randperm(rows(DATA)),:); %randomise the data
d = floor(round(rows(DATA)*4/5)/5)*5;
data = DATA(1:d,:);finaltestData = DATA(d+1:rows(DATA),:);
endif

p = [1:(rows(data)/5);(rows(data)/5)+1:2*(rows(data)/5);2*(rows(data)/5)+1:3*(rows(data)/5);3*(rows(data)/5)+1:4*(rows(data)/5);4*(rows(data)/5)+1:rows(data)];
randomArrayIndex = randperm(rows(data));
labels = unique(DATA(:,columns(DATA)));
number_of_labels = rows(labels);
%range_of_K = ceil(0.1*rows(data));
range_of_K = 10;
for K = 1:range_of_K
    trainIndex = randomArrayIndex([p(1,:) p(2,:) p(3,:) p(4,:)]);
    cvIndex = randomArrayIndex([p(5,:)]);
    trainData = data(trainIndex,:);
    cvData =  data(cvIndex,:);
    X = trainData(:,1:columns(trainData)-1);Y = trainData(:,columns(trainData));
    Y = Y';
    m_train  = rows(trainData); %number of training examples
    x = cvData(:,1:columns(cvData)-1);y = cvData(:,columns(cvData)); 
    m_cv = rows(cvData); %number of test examples
    y = y';
    for i = 1:m_cv
      for j = 1:m_train
        D(i,j) = distance(X(j,:),x(i,:)); %distance matrix
      endfor
    endfor
    for j = 1:m_cv
      A(1,:) = D(j,:);
      A(2,:)=Y(1,:);
      B = sortrows(A',1)';
      C = B(:,1:K);
      count = zeros(number_of_labels,1);
      for i= 1:K
        for k = 1:number_of_labels
          if(C(2,i)==labels(k,1))
            count(k,1)++;
          endif  
        endfor
      endfor  
      for k = 1:number_of_labels
        if(max(count)==count(k,1))
          class(1,j) = labels(k,1);
        endif
      endfor    
    endfor
    total=0;
    for j = 1:m_cv   % You can change the k here
      if(class(1,j)==y(1,j))
        total=total+1;
      endif
    endfor
    accuracy(K,1)=total/m_cv;
  %endfor
endfor
for t = 1:range_of_K
final_accuracy(t,:) = mean(accuracy(t,:));
final_accuracy(t,2) = t;
endfor
finalK=sortrows(final_accuracy)(range_of_K,2);
printf("\nAfter cross validation,the best accuracy is achieved at K = %d\n\n",finalK);
printf("This K = %d will be used for testing in final test data\n\n",finalK);
printf("Program paused,Press Enter for final testing\n\n");
pause; 

Z = data(:,1:columns(data)-1);Zlabel = data(:,columns(data));
Zlabel = Zlabel';
m  = rows(data); %number of training examples
z = finaltestData(:,1:columns(finaltestData)-1);zlabel = finaltestData(:,columns(finaltestData));
zlabel = zlabel';
m_test = rows(finaltestData); %number of test examples
for i = 1:m_test
  for j = 1:m
    Dtest(i,j) = distance(Z(j,:),z(i,:)); %distance matrix
  endfor
endfor
for j = 1:m_test
  P(1,:) = Dtest(j,:);
  P(2,:)=Zlabel(1,:);
  Q = sortrows(P',1)';
  R = Q(:,1:finalK);
  count = zeros(number_of_labels,1);
  for i= 1:finalK
    for k = 1:number_of_labels
      if(R(2,i)==labels(k,1))
        count(k,1)++;
      endif  
    endfor    
  endfor    
  for k = 1:number_of_labels
    if(max(count)==count(k,1))
    classFinal(1,j) = labels(k,1);
    endif
  endfor
endfor
total=0;
for j = 1:m_test
  if(classFinal(1,j)==zlabel(1,j))
    total=total+1;
  endif
endfor
ACCURACY=total/m_test;
printf("Accuracy on final test data = %f\n",ACCURACY);

toc;
