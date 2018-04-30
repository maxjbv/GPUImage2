public class OldFilmEffect: BasicOperation {
    
    public var sepiaValue: Float = 0.5 { didSet { uniformSettings["sepiaValue"] = sepiaValue } }
    public var noiseValue: Float = 0.3 { didSet { uniformSettings["noiseValue"] = noiseValue } }
    public var scratchValue: Float = 0.5 { didSet { uniformSettings["scratchValue"] = scratchValue } }
    public var innerVignetting: Float = 0.3 { didSet { uniformSettings["innerVignetting"] = innerVignetting } }
    public var outerVignetting: Float = 0.1 { didSet { uniformSettings["outerVignetting"] = outerVignetting } }
    public var randomValue: Float = 10.0 { didSet { uniformSettings["randomValue"] = randomValue } }
    public var timeLapse: Float = 0.5 { didSet { uniformSettings["timeLapse"] = timeLapse } }
    
    public var u_time: Float = 0.5 { didSet { uniformSettings["u_time"] = u_time } }
    
    
    public init() {
        super.init(fragmentShader:OldFilmEffectFragmentShader, numberOfInputs:1)
        
        ({sepiaValue = 0.5})()
        ({noiseValue = 0.3})()
        ({scratchValue = 0.5})()
        ({innerVignetting = 0.3})()
        ({outerVignetting = 0.1})()
        ({randomValue = 10.0})()
        ({timeLapse = 0.5})()
        ({u_time = 0.5})()
    }
}
