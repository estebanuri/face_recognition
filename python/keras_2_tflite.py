import tensorflow.lite as lite
import argparse

def parse_args():

    parser = argparse.ArgumentParser(description='Keras to TensorFlow Lite converter')

    parser.add_argument('--input_keras',
                        required=True,
                        type=str,
                        help='The input Keras file model (.h5)')

    parser.add_argument('--output_tflite',
                        required=True,
                        type=str,
                        help='The output TensorFlow Lite file model (.tflite)')

    parser.add_argument('--post_quantize',
                        required=False,
                        type=bool,
                        help='Use post-quantization')

    args = parser.parse_args()
    return args

def convert(args):

    input_file = args.input_keras
    output_file = args.output_tflite

    # Converts the Keras model to TensorFlow Lite
    converter = lite.TocoConverter.from_keras_model_file(input_file)
    converter.post_training_quantize = True
    tflite_model = converter.convert()
    open(output_file, "wb").write(tflite_model)


def run():
    args = parse_args()
    convert(args)

if __name__ == "__main__":
    run()