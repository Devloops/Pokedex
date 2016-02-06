//
//  Pokemon.swift
//  Pokedex
//
//  Created by Amr Sami on 2/5/16.
//  Copyright © 2016 Amr Sami. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _hieght: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLvl: String!
    private var _pokemonUrl: String!
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var height: String {
        if _hieght == nil {
            _hieght = ""
        }
        return _hieght
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLvl: String {
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        return _nextEvolutionLvl
    }
    
    init(name: String, pokedexId: Int) {
        _name = name
        _pokedexId = pokedexId
        
        _pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: downloadCompleted) {
        
        let url = NSURL(string: _pokemonUrl)!
        Alamofire.request(.GET, url).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            
            if let jsonDict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let weight = jsonDict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = jsonDict["height"] as? String {
                    self._hieght = height
                }
                
                if let attack = jsonDict["attack"] as? Int {
                    self._attack = "\(attack)"
                }

                if let defense = jsonDict["defense"] as? Int {
                    self._defense = "\(defense)"
                }

                if let types = jsonDict["types"] as? [Dictionary<String, String>] where types.count > 0 {
                    if let name = types[0]["name"] {
                        self._type = name.capitalizedString
                    }
                    
                    if types.count > 1 {
                        for var i = 1; i < types.count; i++ {
                            if let name = types[i]["name"] {
                                self._type! += "/\(name.capitalizedString)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }

                if let descArr = jsonDict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                    
                    if let urlString  = descArr[0]["resource_uri"] {
                        let url = NSURL(string: "\(URL_BASE)\(urlString)")!
                        Alamofire.request(.GET, url).responseJSON(completionHandler: { (response) -> Void in
                            
                            if let descriptionJsonDict = response.result.value as? Dictionary<String, AnyObject> {
                                if let description = descriptionJsonDict["description"] as? String {
                                    self._description = description
                                }
                            }
                            
                            completed()
                            
                        })
                    }
                    
                } else {
                    self._description = ""
                }
                
                if let evolutions = jsonDict["evolutions"] as? [Dictionary<String, AnyObject>] where evolutions.count > 0 {
                    if let to = evolutions[0] ["to"] as? String {
                        if to.rangeOfString("mega") == nil {
                            //mega not found
                            if let url = evolutions[0]["resource_uri"] as? String {
                                let newStr = url.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                                let num = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                                self._nextEvolutionId = num
                                self._nextEvolutionTxt = to
                                
                                if let lvl = evolutions[0]["level"] as? Int {
                                    self._nextEvolutionLvl = "\(lvl)"
                                }
                            }
                        }
                    }
                }

                
            }
            
        }
        
    }
}