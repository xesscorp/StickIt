import sys
from PyQt4 import QtGui
from xstools.xsmemio import *
from xstools.xsdutio import *
import matplotlib.pyplot as plt

USB_ID = 0
RAM_ID = 255
CTRL_ID = 254

# Create an object for reading the samples stored in SDRAM.
ram = XsMemIo(xsusb_id=USB_ID, module_id=RAM_ID)
# Create an object for controlling and monitoring the codec sampling.
ctrl = XsDutIo(xsusb_id=USB_ID, module_id=CTRL_ID, dut_output_widths=[1, 1], dut_input_widths=[1, 1])

class RecordPlayback(QtGui.QWidget):
    
    def __init__(self):
        super(RecordPlayback, self).__init__()
        
        self.initUI()
        
        
    def initUI(self):      

        recordb = QtGui.QPushButton('Record', self)
        recordb.setCheckable(True)
        recordb.move(50, 10)

        recordb.clicked[bool].connect(self.record)

        playb = QtGui.QPushButton('Play', self)
        playb.setCheckable(True)
        playb.move(150, 10)

        playb.clicked[bool].connect(self.play)

        self.setGeometry(300, 300, 280, 45)
        self.setWindowTitle('Record/Playback Control')
        self.show()
        
    def record(self, pressed):
        source = self.sender()
        if pressed:
            ctrl.write(1,0) # Start recording.
        else:
            ctrl.write(0,0) # Stop recording.
        
    def play(self, pressed):
        source = self.sender()
        if pressed:
            ctrl.write(0,1)
            ctrl.write(1,1) # Start playback.
        else:
            ctrl.write(0,0) # Stop playback.
            
        
def main():
    
    app = QtGui.QApplication(sys.argv)
    ex = RecordPlayback()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()    