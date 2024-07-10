import React from "react";
import { View, ScrollView } from "react-native";
import Drake from "./Drake";
import ChipButton from "./ChipButton";

const ChipsScroll = ({ flexValue }: { flexValue: number }) => {



  return (
    <View style={[styles.frame, { flex: flexValue }]}>
        <ScrollView horizontal style={[styles.scrollView, { flex: flexValue }]}>
            <ChipButton />
            <ChipButton />
            <ChipButton />
            <ChipButton />
            <ChipButton />
        </ScrollView>
    </View>
  );
};



const styles = {
    frame: {
        justifyContent: 'center',
        alignItems: 'center',
    },
    scrollView: {
        flex: 1,
        height: '50%',
        backgroundColor: 'blue',
    }  // Add a background color for visibility
}

export default ChipsScroll;