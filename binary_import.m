clear; clc;

% Serial port parameters
port = 'COM10';  
baudrate = 2000000;  % Baud rate (same as transmission rate from ESP32)


% Open serial port with Input Buffer
s = serial(port, 'BaudRate', baudrate, 'InputBufferSize', 4096);
%s = serial(port, 'BaudRate', baudrate, 'InputBufferSize', 8192);
set(s, 'Timeout', 1);  % Set the Timeout to 1 second
fopen(s);

% Create file to save the received data as integers
filename = '35KHz.txt';
fileID = fopen(filename, 'w');

% Total number of samples to read
totalSamples = 131072;  % Change this to the total number of samples you expect to receive

% Define the number of samples per packet
samplesPerPacket = 1024;

% Pre-allocate the data array to hold the received samples
receivedData = zeros(totalSamples, 1, 'int32');

tic;
% Read data packet by packet
numPackets = totalSamples / samplesPerPacket;
for i = 1:numPackets
    % Read one data packet as binary data
    dataPacket = uint8([]);  % Initialize an empty uint8 array
    while length(dataPacket) < samplesPerPacket * 4 % 4 bytes per sample
        remainingBytes = samplesPerPacket * 4 - length(dataPacket);
        dataChunk = fread(s, remainingBytes, 'uint8');  % Read samples in packets from serial port 
        dataPacket = [dataPacket; dataChunk];
    end
    
    % Convert the binary data to int32
    dataChunk = typecast(dataPacket, 'int32');
    
    % Determine the actual number of samples received in this chunk
    numSamplesReceived = length(dataChunk); 
    
    % Store the received data in the main data array
    startIndex = (i - 1) * samplesPerPacket + 1;
    endIndex = startIndex + numSamplesReceived - 1;
    receivedData(startIndex:endIndex) = dataChunk;
end
toc

% Save the integer values in the file
fprintf(fileID, '%d\n', receivedData);

% Close the file and serial port
fclose(fileID);
fclose(s);
delete(s);
clear s;
