//
//  Socket.swift
//  mazespritekit
//
//  Created by Victor Lucas on 15/05/2019.
//  Copyright © 2019 tor4. All rights reserved.
//

import UIKit

func getPlayerPosition(from screenSize:CGSize) -> [Int:CGPoint]{
    
    let left = -1 * screenSize.width + 60
    let right = screenSize.width - 60
    let bottom = -1 * screenSize.height + 60
    let top = screenSize.height - 60
    
    let position = [1:CGPoint(x: left, y: top),
                    2:CGPoint(x: right , y: top ),
                    3:CGPoint(x: left , y: bottom ),
                    4:CGPoint(x: right , y: bottom )]
    
    return position
}
