import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const BlueCircle = () => {
  return (
    <View style={styles.circle}>
      <Text style={styles.text}>gg ez</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  circle: {
    width: 550, // Diameter of the circle
    height: 550, // Diameter of the circle
    borderRadius: 550, // Half of the width/height to make it a circle
    backgroundColor: 'rgb(123,222,44)', // Circle color
    justifyContent: 'center', // Center the text vertically
    alignItems: 'center', // Center the text horizontally
    position: 'absolute',
    top: '50%',
    left: '50%',
    marginTop: -275, // Offset by half the height to center
    marginLeft: -275, // Offset by half the width to center
  },
  text: {
    color: 'white', // Text color
    fontSize: 100, // Text size
    fontStyle: 'italic', // Italic text
    fontWeight: 'bold', // Bold text
  },
});

export default BlueCircle;
