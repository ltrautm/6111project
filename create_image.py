'''Automatically find USB Serial Port (jodalyst 8/2019)
'''
import serial.tools.list_ports
from PIL import Image
import numpy as np

def get_usb_port():
    usb_port = list(serial.tools.list_ports.grep("USB"))
    if len(usb_port) == 1:
        print("Automatically found USB-Serial Controller: {}".format(usb_port[0].description))
        return usb_port[0].device
    else:
        ports = list(serial.tools.list_ports.comports())
        port_dict = {i:[ports[i],ports[i].vid] for i in range(len(ports))}
        usb_id=None
        for p in port_dict:
            #print("{}:   {} (Vendor ID: {})".format(p,port_dict[p][0],port_dict[p][1]))
            #print(port_dict[p][0],"UART")
            print("UART" in str(port_dict[p][0]))
            if port_dict[p][1]==1027 and "UART" in str(port_dict[p][0]): #for generic USB Devices
                usb_id = p
        if usb_id== None:
            return False
        else:
            print("Found it")
            print("USB-Serial Controller: Device {}".format(p))
            return port_dict[usb_id][0].device

s = get_usb_port()  #grab a port
print("USB Port: "+str(s)) #print it if you got
if s:
    ser = serial.Serial(port = s,
        baudrate=115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=0.01) #auto-connects already I guess?
    print("Serial Connected!")
    if ser.isOpen():
         print(ser.name + ' is open...')
else:
    print("No Serial Device :/ Check USB cable connections/device!")
    exit()

test_data = []
count = 0
temp = []
try:
    print("Reading...")
    while True:
        data = ser.read(1) #read the buffer (99/100 timeout will hit)
        if data != b'':  #if not nothing there.
            print("data", data[0] << 4, "num data received", count)
            count += 1

            #RED
            # if count <= 320*240:
            #     # print("current count", count)
            #     test_data.append((data[0] << 4, 0, 0))
            # else:
            #     print("uh oh" ,count)
            #     break

        
            #  Actual
            temp.append(data[0] << 4)
            if count % 3 == 0:
                test_data.append(tuple(temp))
                temp = []

            if count == 240*320*3:
                break
    print("done!")
    # print("v1", test_data)
    test_data2 = np.array(test_data, dtype=np.uint8).reshape(240, 320, 3)
    # print("reshaped", test_data2)
    new_image = Image.fromarray(test_data2, mode='RGB')
    new_image.save('test_image.png')

 


except Exception as e:
    print(e)
