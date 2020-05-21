//
//  communication.swift
//  SBox
//
//  Created by 黃仕杰 on 2018/4/21.
//  Copyright © 2018年 SBox. All rights reserved.
//

import UIKit
import Foundation


public class WiFi_Communication: NSObject, StreamDelegate{

    var iStream: InputStream! ; //接收 read
    var oStream: OutputStream! ; //送出 write
    var isAvailable: Int = 0; // 0已斷線 , 1斷線中 , 2連線中 , 3已連線 ((1尚未使用
    
    //=======================================================
    func connective(addr: CFString , port: UInt32) -> Bool{
        
        if(isAvailable > 1){ return false }
        
        isAvailable = 2;
        
        var readStream :Unmanaged<CFReadStream>?;
        var writeStream:Unmanaged<CFWriteStream>?;
        
        CFStreamCreatePairWithSocketToHost(nil, addr as CFString, port, &readStream, &writeStream);
        
        iStream = readStream!.takeRetainedValue();
        oStream = writeStream!.takeRetainedValue();
        
        self.iStream.delegate = self;
        self.oStream.delegate = self;
        
        iStream.open();
        oStream.open();
        
        return true;
    }
    
    
    //============================================================
    func sendData(_ string: String) -> Void{
        
        if(isAvailable==3){
            let tmp  = string;
            var sendData = tmp.data(using: String.Encoding.utf8)
            let uData = sendData?.withUnsafeBytes({ (buffer:UnsafePointer<UInt8>?) -> UnsafePointer<UInt8> in
                return buffer!.advanced(by: 0)
            })
            oStream.write(uData!, maxLength: sendData!.count);
        }
    }
    
    func sendPNG() -> Void {
        let img = UIImage.init(named: "3dlogo.png");
        let sendData = UIImagePNGRepresentation(img!);
        let uData = sendData?.withUnsafeBytes({ (buffer:UnsafePointer<UInt8>?) -> UnsafePointer<UInt8> in
            return buffer!.advanced(by: 0)
        })
        oStream.write(uData!, maxLength: sendData!.count);
    }
    
    //=============================================================
    func sys(_ bool: Bool) -> Void{
        switch(bool){
        case false:
            if(isAvailable != 0){
                iStream.close();
                oStream.close();
                isAvailable = 0;
                print("__Disconnected__");
            }
            break;
            
        case true:
            isAvailable = 3;
            print("__Open__");
            break;
        }
    }
    
    
    //=============================================================
    func receive( available: @escaping (_ msg: String)->Void ) -> Void{
        DispatchQueue.global().async {
            print("___RECEICE___")
            while(self.isAvailable > 1){
                if(self.iStream.hasBytesAvailable){
                    var buf = Array(repeating: UInt8(0), count: 1024);
                    var n: Int = 0;
                    n = (self.iStream?.read(&buf, maxLength: 1024))!;
                    
                    if(n < 0) {  print(n); break; }
                    
                    let data = Data(bytes: buf, count: n);
                    let string = String(data: data, encoding: .utf8)!;
                    
                    if (string.description == "") { break; }
                    
                    let s = string.trimmingCharacters(in: .whitespacesAndNewlines);
                    print("回傳值>>> \(s)");
                    DispatchQueue.main.async {
                        available(s);
                    }
                }
            }
            self.sys(false);
        }
    }
    
    
    
    
    
    //=============================================================
    /*func receiveData() -> String{
        print("RECEIVE222")
        
        var strReceive: String = "";
        var n: Int = 0;
        var buf = Array(repeating: UInt8(0), count: 1024);
        
        n = (self.iStream?.read(&buf, maxLength: 1024))!;
        
        if(n>0){
            let data = Data(bytes: buf, count: n);
            let string = String(data: data, encoding: .utf8);
            if let stringTo = string?.replacingOccurrences(of: "\n", with: ""){
                strReceive = stringTo;
                print("回傳值>>> \(strReceive)");
            }
        }else{
            self.sys(false);
        }
        
        return strReceive;
    }*/
}
