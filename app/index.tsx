import React from 'react';
import { Text, View, StyleSheet, StatusBar } from 'react-native';
import { SafeAreaProvider, SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import Main from '@/components/Main';
import { registerRootComponent } from 'expo';

export default function Home() {
  const insets = useSafeAreaInsets();

  return (
      <View style={styles.container}>
        <StatusBar translucent backgroundColor="transparent" barStyle="light-content" />
        <View style={[styles.topSafeArea, { height: insets.top }]}/>
        <Main />
      </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'purple', // or your desired background color
  },
  topSafeArea: {
    backgroundColor: 'pink', // or your desired background color
  },
});

registerRootComponent(Home);