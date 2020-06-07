//
//  CSLTemperatureTagListCell.swift
//  CS108iOSClient
//
//  Created by Carlson Lam on 2/3/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

@objcMembers class CSLTemperatureTagListCell: UITableViewCell {
    
    @IBOutlet weak var lbEPC: UILabel!
    @IBOutlet weak var lbTemperature: UILabel!
    @IBOutlet weak var lbRssi: UILabel!
    @IBOutlet weak var lbTagStatus: UIButton!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var viewAccessory: UIView!
    @IBOutlet weak var accessory: UIButton!
    @IBOutlet weak var viTemperatureCell: UIView!
    @IBOutlet weak var lbPortNumber: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func calculateCalibratedTemperatureValue(_ tempCodeInHexString: String?, calibration calibrationInHexString: String?) -> Double {
        var tmp: UInt32 = 0
        var temperatureCode: UInt32 = 0
        var code1: UInt32 = 0
        var temp1_1: UInt32
        var temp1_2: UInt32
        var temp1: UInt32 = 0
        var code2_1: UInt32
        var code2_2: UInt32
        var code2: UInt32 = 0
        var temp2: UInt32 = 0
        var temperatureValue = 0.0

        //temperature code
        temperatureCode = UInt32(tempCodeInHexString ?? "0", radix: 16)!
        temperatureCode &= 0x00000fff //least significant bits

        //Calibration - CODE1
        tmp = UInt32((calibrationInHexString as NSString?)?.substring(with: NSRange(location: 4, length: 4)) ?? "0", radix: 16)!
        temp1_1 = (tmp << 7) & 0x00000780 //capture the partial TEMP1 from the 0x9 address
        code1 = (tmp >> 4) & 0x00000fff //least significant bits

        //Calibration - TEMP1
        tmp = UInt32((calibrationInHexString as NSString?)?.substring(with: NSRange(location: 8, length: 4)) ?? "0", radix: 16)!
        code2_1 = (tmp << 3) & 0x00000ff8 //capture the partial CODE2 from the 0xA address
        temp1_2 = (tmp >> 9) & 0x0000007f //least significant bits
        temp1 = temp1_1 + temp1_2

        //Calibration - CODE2
        tmp = UInt32((calibrationInHexString as NSString?)?.substring(with: NSRange(location: 12, length: 4)) ?? "0", radix: 16)!
        code2_2 = (tmp >> 13) & 0x00000007 //least significant bits
        code2 = code2_1 + code2_2

        //Calibration - TEMP2
        temp2 = (tmp >> 2) & 0x000007ff //least significant bits

        // calculate temperature value from temperature code
        //Temperature in Degrees Celsius=(1/10)[TEMP2−TEMP1CODE2−CODE1(C−CODE1)+TEMP1−800]
        temperatureValue = (Double(temp2) - Double(temp1)) / (Double(code2) - Double(code1))
        temperatureValue *= Double(temperatureCode) - Double(code1)
        temperatureValue += Double(temp1)
        temperatureValue -= 800
        temperatureValue /= 10

        return temperatureValue
    }

    class func calculateCalibratedTemperatureValue(forXerxes tempCode: UInt16, temperatureCode2 tempCode2: UInt16, temperature2 temp2: UInt16, temperatureCode1 tempCode1: UInt16, temperature1 temp1: UInt16) -> Double {
        //int FormatCode = (add_15 >> 13) & 0x07;
        //int Parity1 = (add_15 >> 12) & 0x01;
        //int Parity2 = (add_15 >> 11) & 0x01;
        let Temperature1 = temp1 & 0x07ff
        let TemperatureCode1 = tempCode1 & 0xffff
        //int RFU = (add_13 >> 13) & 0x07;
        //int Parity3 = (add_13 >> 12) & 0x01;
        //int Parity4 = (add_13 >> 11) & 0x01;
        let Temperature2 = temp2 & 0x07ff
        let TemperatureCode2 = tempCode2 & 0xffff

        let CalTemp1 = 0.1 * Double(Temperature1) - 60
        let CalTemp2 = 0.1 * Double(Temperature2) - 60
        let CalCode1 = 0.0625 * Double(TemperatureCode1)
        let CalCode2 = 0.0625 * Double(TemperatureCode2)

        let slope = (CalTemp2 - CalTemp1) / (CalCode2 - CalCode1)
        let TEMP = slope * (Double(tempCode) - CalCode1) + CalTemp1

        return TEMP
    }

    func spinTemperatureValueIndicator() {
        if (lbTemperature.text == "  -  ") {
            lbTemperature.text = "  \\  "
        } else if (lbTemperature.text == "  \\  ") {
            lbTemperature.text = "  |  "
        } else if (lbTemperature.text == "  |  ") {
            lbTemperature.text = "  /  "
        } else if (lbTemperature.text == "  /  ") {
            lbTemperature.text = "  -  "
        } else {
            lbTemperature.text = "  -  "
        }
    }
}
