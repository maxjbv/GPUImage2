public class GreyScale: BasicOperation {
    public init() {
        super.init(fragmentShader:GreyScaleFragmentShader, numberOfInputs:1)
    }
}
