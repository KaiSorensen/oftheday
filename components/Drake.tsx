import React from 'react';
import { Image, View, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  frame: {

  },
  image: {
  // Make the image take up all available space of its container
    width: '100%',
    height: '100%',
  },
});

const Drake = () => {
  return (
    <View style={styles.frame}>
      <Image
          source={require('@/assets/images/drakeLNCL.jpg')}
          style={styles.image}
          resizeMode="stretch"
      />
    </View>
  );
}

export default Drake;
