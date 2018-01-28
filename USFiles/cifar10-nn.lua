require 'paths'
require 'itorch'

if (not paths.filep("cifar10torchsmall.zip")) then
   os.execute('wget -c https://s3.amazonaws.com/torch7/data/cifar10torchsmall.zip')
   os.execute('unzip cifar10torchsmall.zip')
end

trainset = torch.load('cifar10-train.t7', 'b64')
testset = torch.load('cifar10-test.t7', 'b64')
classes = {'airplane', 'automobile','bird','cat','deer','dog','frog','horse','ship','truck'}

print(trainset)
print(#trainset.data)

itorch.image(trainset.data[100])
print(classes[trainset.label[100]])

setmetatable(trainset,
   {__index = function(t,i)
         return {t.data[i],t.label[i]}
      end}
);

trainset.data = trainset.data:double() --convert data from ByteTensor to Double

function trainset:size()
   return self.data:size(1)
end

print(trainset:size()) -- just to test
print(trainset[33]) -- load sample number 33 in this case
itorch.image(trainset[33][1])

redChannel = trainset.data[{ {},{1},{},{} }] --this picks {all images, 1st channel, all vertical pixels, all horizontal pixels}
print(#redChannel)

--select the 150th to 300th data elements of the data
print(trainset.data{150,300})

mean = {} --store mean, to normalize the test set in the future
stdv = {} --store the standard-deviation for the future
for i=1,3 do --over each image channel
   mean[i] = trainset.data[{ {},{i},{},{} }]:mean() -- mean estimation
   print('Channel ' .. i .. ', Mean:' .. mean[i])
   trainset.data[{ {},{i},{},{} }]:add(-mean[i]) -- mean subtraction
   
   stdv[i] = trainset.data[{ {},{i},{},{} }]:std() -- std estimation
   print('Channel ' .. i .. ', Standard Deviation:' .. stdv[i])
   trainset.data[{ {},{i},{},{} }]:div(stdv[i]) -- std scaling
end

--Neural Net
net = nn.Sequential()
net:add(nn.SpatialConvolution(3,6,5,5)) -- 3 input image channels, 6 output channels, 5x5 convolution kernel
net:add(nn.ReLU()) --non-linearity
net:add(nn.SpatialMaxPooling(2,2,2,2)) -- A max-pooling operation that looks at 2x2 windows and finds the max.
net:add(nn.SpatialConvolutions(6,16,5,5))
net:add(nn.ReLU()) --non-linearity
net:add(nn.SpatialMaxPooling(2,2,2,2))
net:add(nn.View(16*5*5)) -- reshapes from a 3D tensor of 16x5x5 into 1D tesnsor
net:add(nn.Linear(16*5*5,120)) -- fully connected layer (matrix multiplication between input and weights)
net:add(nn.ReLU())
net:add(nn.Linear(120,84))
net:add(nn.ReLU())
net:add(nn.Linear(84,10)) -- 10 is the number of outputs of the network (this case, 10 digits)
net:add(nn.LogSoftMax()) -- converts the output to a log-probability. for classification

-- Loss Function
criterion = nn.ClassNLLCriterion()
trainer = nn.StochasticGradient(net,criterion)
trainer.learningRate = 0.001
trainer.maxIteration = 5 -- 5 epochs of training

trainer:train(trainset)

-- Test nn, print accuracy
print(classes[testset.label[100]])
itorch.image(testset.data[100])

testset.data = testset.data:double() -- convert from ByteTensor to DoubleTensor
for i=1,3 do -- over each image channel
   testset.data[{ {},{i},{},{} }]:add(-mean[i]) -- mean subtraction
   testset.data[{ {},{i},{},{} }]:div(stdv[i]) -- std scaling
end

-- print the mean and standard-deviation of exmaple 100
horse = testset.data[100]
print(horse.mean(),horse:std())
-- now what does our nn think
print(classes[testset.label[100]])
itorch.image(testset.data[100])
predicted = net:forward(testset.data[100])
-- output of the nn is in Log-Probabilities
-- convert to probabilities
print(predicted:exp())

-- tag each probability with class-name
for i=1,predicted:size(1) do
   print(classes[i],predicted[i])
end

-- how many were correct?
correct = 0
for i=1,10000 do
   local groundtruth = testset.label[i]
   local prediction = net:forward(testset.data[i])
   local confidences, indices = torch.sort(prediction, true) -- true means descending
   if groundtruth == indices[1] then
      correct = correct + 1
   end
end

print(correct,100*correct/10000 .. '%')

-- let's see what classes performed well compared to which didn't
class_performance = {0,0,0,0,0,0,0,0,0,0}
for i=1,10000 do
   local groundtruth = testset.label[i]
   local prediction = net:forward(testset.data[i])
   local confidences, indices = torch.sort(prediction, true)
   if groundtruth == indices[1] then
      class_performance[groundtruth] = class_performance[groundtruth] + 1
   end
end

for i=1,#classes do
   print(classes[i],100*class_performance[i]/1000 .. '%')
end

-- run it on GPU
require 'cunn';

net = net:cuda()
criterion = criterion:cuda()
trainset.data = trainset.data:cuda()
trainset.label = trainset.label:cuda()

-- train on GPU
trainer = nn.StochasticGradient(net,criterion)
trainer.learningRate = 0.001
trainer.maxIteration = 5 -- 5 epochs of training

trainer:train(trainset)

-- try inscreasing the size of your nn (args 1 and 2 of SpatialConvolution), see what kind of speedup we get
