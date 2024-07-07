import React from "react";
import { View } from "react-native";
import Drake from "./Drake";

const Content = ({ flexValue }: { flexValue: number }) => {
    return (
      <View style={[styles.content, { flex: flexValue } ]}>
          <Drake/>
      </View>
    );
  };

const styles = {
    content: {
        width: '90%',
        height: '90%',
        borderRadius: '60%',
        overflow: 'hidden',
        alignSelf: 'center',
        justifyContent: 'center',
    }
}

export default Content;